import HealthKit
import WatchKit
import Foundation
import KeepScoreKit

class ScoreOrActivitySelectionInterfaceController: WKInterfaceController, MatchSetupDelegate, RewindScoreDelegate, ReviewMatchDelegate {
    
    @IBOutlet var activityGroup: WKInterfaceGroup!
    @IBOutlet var activityTable: WKInterfaceTable!
    @IBOutlet var scoreGroup: WKInterfaceGroup!
    @IBOutlet var homeTeamScoreButton: WKInterfaceButton!
    @IBOutlet var awayTeamScoreButton: WKInterfaceButton!
    @IBOutlet var matchRunningTimeTimer: WKInterfaceTimer!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var distanceTravelledLabel: WKInterfaceLabel!
    
    let healthStore = HKHealthStore()
    
    var startDateKeyPath = "startDate"
    var heartRateKeyPath = "heartRate"
    var distanceTravelledKeyPath = "distanceTravelled"
    var caloriesBurnedKeyPath = "caloriesBurned"
    var activitySelectionViewModel = ActivitySelectionViewModel()
    var matchViewModel: MatchViewModel?
    var workoutSession: HKWorkoutSession?
    var workoutSessionManager: WorkoutSessionManager?
    var matchScoreWasRewound = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setGroupVisibility()
    }

    override func willActivate() {
        super.willActivate()
        
        setGroupVisibility()
        if let matchViewModel = matchViewModel {
            addObservers()
            
            if let homeTeamScore = matchViewModel.match?.homeTeamScore, let awayTeamScore = matchViewModel.match?.awayTeamScore, matchScoreWasRewound {
                self.homeTeamScoreButton.setTitle("\(homeTeamScore)")
                self.awayTeamScoreButton.setTitle("\(awayTeamScore)")
            }
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        if let _ = matchViewModel {
            removeObservers()
        }
    }
    
    fileprivate func setGroupVisibility() {
        if let _ = matchViewModel {
            scoreGroup.setHidden(false)
            activityGroup.setHidden(true)
        } else {
            scoreGroup.setHidden(true)
            activityGroup.setHidden(false)
            matchRunningTimeTimer.setHidden(true)
            loadSupportedActivities()
        }
        updateMenu()
    }

    fileprivate func loadSupportedActivities() {
        let supportedActivities = activitySelectionViewModel.supportedActivities
        activityTable.setNumberOfRows(supportedActivities.count, withRowType: "ActivityTableRowController")
        
        for (index, activityType) in supportedActivities.enumerated() {
            let row = activityTable.rowController(at: index) as! ActivityTableRowController
            row.titleLabel.setText(activityType.getTitle())
        }
    }
    
    fileprivate func addObservers() {
        if let matchViewModel = matchViewModel {
            matchViewModel.addObserver(self, forKeyPath: startDateKeyPath, options: [.initial, .new], context: nil)
            matchViewModel.addObserver(self, forKeyPath: distanceTravelledKeyPath, options: [.initial, .new], context: nil)
            matchViewModel.addObserver(self, forKeyPath: heartRateKeyPath, options: [.initial, .new], context: nil)
            matchViewModel.addObserver(self, forKeyPath: caloriesBurnedKeyPath, options: [.initial, .new], context: nil)
        }
    }
    
    fileprivate func removeObservers() {
        if let matchViewModel = matchViewModel {
            matchViewModel.removeObserver(self, forKeyPath: "startDate")
            matchViewModel.removeObserver(self, forKeyPath: "distanceTravelled")
            matchViewModel.removeObserver(self, forKeyPath: "heartRate")
            matchViewModel.removeObserver(self, forKeyPath: "caloriesBurned")
        }
    }
    
    fileprivate func updateMenu() {
        self.clearAllMenuItems()
        if let _ = matchViewModel {
            self.addMenuItem(with: .decline, title: "End", action: #selector(ScoreOrActivitySelectionInterfaceController.endMenuItemTapped))
            self.addMenuItem(with: .repeat, title: "Rewind Score", action: #selector(ScoreOrActivitySelectionInterfaceController.rewindScoreItemTapped))
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        resetMatchInfo()
        
        let supportedActivities = activitySelectionViewModel.supportedActivities
        let selectedActitity = supportedActivities[rowIndex]
        let matchSetupViewModel = MatchSetupViewModel(activityType: selectedActitity, healthStore: self.healthStore)
        matchSetupViewModel.delegate = self
        return matchSetupViewModel
    }
    
    func resetMatchInfo() {
        activityGroup.setHidden(true)
        homeTeamScoreButton.setTitle("-")
        awayTeamScoreButton.setTitle("-")
        heartRateLabel.setText("")
        distanceTravelledLabel.setText("")
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            switch (keyPath) {
            case distanceTravelledKeyPath:
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? Double, newValue > 0.0 {
                    debugPrint("Distance travelled updated: \(matchViewModel?.distanceTravelledForDisplay ?? "")")
                    distanceTravelledLabel.setText(matchViewModel!.distanceTravelledForDisplay)
                    distanceTravelledLabel.setHidden(false)
                }
            case heartRateKeyPath:
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? Double, newValue > 0.0 {
                    debugPrint("Heart Rate updated: \(matchViewModel!.heartRateForDisplay)")
                    heartRateLabel.setText(matchViewModel!.heartRateForDisplay)
                    heartRateLabel.setHidden(false)
                }
            case caloriesBurnedKeyPath:
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? Double, newValue > 0.0 {
                    debugPrint("Calories Burned updated: \(matchViewModel?.caloriesBurnedForDisplay ?? "")")
                }
            case startDateKeyPath:
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? Date {
                    matchRunningTimeTimer.setDate(newValue)
                    matchRunningTimeTimer.setHidden(false)
                    matchRunningTimeTimer.start()
                }
            default:
                break;
            }
        }
    }
    
    // MARK: Match Setup Delegate
    
    func matchSetupDidComplete(_ match: Match, useHealthKit: Bool) {
        createMatchViewModel(match, useHealthKit: useHealthKit)
        if let matchViewModel = matchViewModel, let startDate = matchViewModel.startDate {
            self.matchRunningTimeTimer.setDate(startDate as Date)
            self.matchRunningTimeTimer.setHidden(false)
        }
        setGroupVisibility()
    }
    
    func createMatchViewModel(_ match: Match, useHealthKit: Bool) {
        guard useHealthKit else {
            self.matchViewModel = MatchViewModel(match: match, useHealthKit: useHealthKit, workoutSessionManager: nil)
            return
        }
        let activityType = ActivityType(rawValue: match.activityType)!
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType.getWorkoutActivityType()
        configuration.locationType = .unknown
        do {
            try workoutSession = HKWorkoutSession(configuration: configuration)
        } catch {
            debugPrint(error)
            return
        }
        
        workoutSessionManager = WorkoutSessionManager(healthStore: healthStore, workoutActivityType: activityType.getWorkoutActivityType(), workoutSession: workoutSession!)
        matchViewModel = MatchViewModel(match: match, useHealthKit: useHealthKit, workoutSessionManager: workoutSessionManager!)

        workoutSession?.delegate = matchViewModel
        workoutSessionManager?.delegate = matchViewModel
        workoutSessionManager?.quantityUpdateDelegate = matchViewModel
        matchViewModel?.startMatch()
    }
    
    // MARK: Rewind Score Delegate {
    
    func matchScoreWasRewound(_ rewindScoreViewModel: RewindScoreViewModel) {
        if let matchViewModel = matchViewModel {
            matchViewModel.match = rewindScoreViewModel.match
            matchScoreWasRewound = true
        }
    }
    
    // MARK: Review Match Delegate
    
    func matchReviewDidSave(_ match: Match) {
        self.matchViewModel = nil
        self.workoutSessionManager = nil
        self.workoutSession = nil
        setGroupVisibility()
    }
    
    func matchReviewDidDiscard(_ match: Match) {
        self.matchViewModel = nil
        self.workoutSessionManager = nil
        self.workoutSession = nil
        setGroupVisibility()
    }
    
    // MARK: IB Actions
    
    @IBAction func homeTeamScoreButtonTapped() {
        WKInterfaceDevice.current().play(.directionUp)
        let newScore = matchViewModel!.incrementHomeTeamScore()
        homeTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func awayTeamScoreButtonTapped() {
        WKInterfaceDevice.current().play(.directionDown)
        let newScore = matchViewModel!.incrementAwayTeamScore()
        awayTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func rewindScoreItemTapped() {
        
        if let matchViewModel = matchViewModel, let match = matchViewModel.match {
            let rewindScoreViewModel = RewindScoreViewModel(match: match)
            rewindScoreViewModel.delegate = self
            presentController(withName: "RewindScoreInterfaceController", context: rewindScoreViewModel)
        }
    }
    
    @IBAction func endMenuItemTapped() {
        matchRunningTimeTimer.stop()
        self.clearAllMenuItems()
        
        if let matchViewModel = matchViewModel {
            let reviewMatchViewModel = ReviewMatchViewModel(match: matchViewModel.match!, workoutSessionManager: workoutSessionManager)
            reviewMatchViewModel.delegate = self
            presentController(withName: "ReviewMatchInterfaceController", context: reviewMatchViewModel)
        }
    }
    
}
