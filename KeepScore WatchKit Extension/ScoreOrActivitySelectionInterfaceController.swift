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
    
    var startDateContext = 0
    var heartRateContext = 0
    var distanceTravelledContext = 0
    var caloriesBurnedContext = 0
    var activitySelectionViewModel = ActivitySelectionViewModel()
    var matchViewModel: MatchViewModel?
    var workoutSession: HKWorkoutSession?
    var workoutSessionManager: WorkoutSessionManager?
    var matchScoreWasRewound = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        setGroupVisibility()
    }

    override func willActivate() {
        super.willActivate()
        
        setGroupVisibility()
        if let matchViewModel = matchViewModel {
            addObservers()
            
            if let homeTeamScore = matchViewModel.match?.homeTeamScore, let awayTeamScore = matchViewModel.match?.awayTeamScore where matchScoreWasRewound {
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
    
    private func setGroupVisibility() {
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

    private func loadSupportedActivities() {
        let supportedActivities = activitySelectionViewModel.supportedActivities
        activityTable.setNumberOfRows(supportedActivities.count, withRowType: "ActivityTableRowController")
        
        for (index, activityType) in supportedActivities.enumerate() {
            let row = activityTable.rowControllerAtIndex(index) as! ActivityTableRowController
            row.titleLabel.setText(activityType.getTitle())
        }
    }
    
    private func addObservers() {
        if let matchViewModel = matchViewModel {
            matchViewModel.addObserver(self, forKeyPath: "startDate", options: [.Initial, .New], context: &startDateContext)
            matchViewModel.addObserver(self, forKeyPath: "distanceTravelled", options: [.Initial, .New], context: &distanceTravelledContext)
            matchViewModel.addObserver(self, forKeyPath: "heartRate", options: [.Initial, .New], context: &heartRateContext)
            matchViewModel.addObserver(self, forKeyPath: "caloriesBurned", options: [.Initial, .New], context: &caloriesBurnedContext)
        }
    }
    
    private func removeObservers() {
        if let matchViewModel = matchViewModel {
            matchViewModel.removeObserver(self, forKeyPath: "startDate")
            matchViewModel.removeObserver(self, forKeyPath: "distanceTravelled")
            matchViewModel.removeObserver(self, forKeyPath: "heartRate")
            matchViewModel.removeObserver(self, forKeyPath: "caloriesBurned")
        }
    }
    
    private func updateMenu() {
        self.clearAllMenuItems()
        if let _ = matchViewModel {
            self.addMenuItemWithItemIcon(.Decline, title: "End", action: "endMenuItemTapped")
            self.addMenuItemWithItemIcon(.Repeat, title: "Rewind Score", action: "rewindScoreItemTapped")
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch (context) {
        case &distanceTravelledContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? Double where newValue > 0.0 {
                debugPrint("Distance travelled updated: \(matchViewModel?.distanceTravelledForDisplay)")
                distanceTravelledLabel.setText(matchViewModel!.distanceTravelledForDisplay)
                distanceTravelledLabel.setHidden(false)
            }
        case &heartRateContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? Double where newValue > 0.0 {
                debugPrint("Heart Rate updated: \(matchViewModel!.heartRateForDisplay)")
                heartRateLabel.setText(matchViewModel!.heartRateForDisplay)
                heartRateLabel.setHidden(false)
            }
        case &caloriesBurnedContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? Double where newValue > 0.0 {
                debugPrint("Calories Burned updated: \(matchViewModel?.caloriesBurnedForDisplay)")
            }
        case &startDateContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? NSDate {
                matchRunningTimeTimer.setDate(newValue)
                matchRunningTimeTimer.setHidden(false)
                matchRunningTimeTimer.start()
            }
        default:
            break;
        }
    }
    
    // MARK: Match Setup Delegate
    
    func matchSetupDidComplete(match: Match, useHealthKit: Bool) {
        createMatchViewModel(match, useHealthKit: useHealthKit)
        if let matchViewModel = matchViewModel, let startDate = matchViewModel.startDate {
            self.matchRunningTimeTimer.setDate(startDate)
            self.matchRunningTimeTimer.setHidden(false)
        }
        setGroupVisibility()
    }
    
    func createMatchViewModel(match: Match, useHealthKit: Bool) {
        guard useHealthKit else {
            self.matchViewModel = MatchViewModel(match: match, useHealthKit: useHealthKit, workoutSessionManager: nil)
            return
        }
        workoutSession = HKWorkoutSession(activityType: match.activityType.getWorkoutActivityType(), locationType: .Unknown)
        workoutSessionManager = WorkoutSessionManager(healthStore: healthStore, workoutActivityType: match.activityType.getWorkoutActivityType(), workoutSession: workoutSession!)
        matchViewModel = MatchViewModel(match: match, useHealthKit: useHealthKit, workoutSessionManager: workoutSessionManager!)

        workoutSession?.delegate = matchViewModel
        workoutSessionManager?.delegate = matchViewModel
        workoutSessionManager?.quantityUpdateDelegate = matchViewModel
        matchViewModel?.startMatch()
    }
    
    // MARK: Rewind Score Delegate {
    
    func matchScoreWasRewound(rewindScoreViewModel: RewindScoreViewModel) {
        if let matchViewModel = matchViewModel {
            matchViewModel.match = rewindScoreViewModel.match
            matchScoreWasRewound = true
        }
    }
    
    // MARK: Review Match Delegate
    
    func matchReviewDidSave(match: Match) {
        self.matchViewModel = nil
        self.workoutSessionManager = nil
        self.workoutSession = nil
        setGroupVisibility()
    }
    
    func matchReviewDidDiscard(match: Match) {
        self.matchViewModel = nil
        self.workoutSessionManager = nil
        self.workoutSession = nil
        setGroupVisibility()
    }
    
    // MARK: IB Actions
    
    @IBAction func homeTeamScoreButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.DirectionUp)
        let newScore = matchViewModel!.incrementHomeTeamScore()
        homeTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func awayTeamScoreButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.DirectionDown)
        let newScore = matchViewModel!.incrementAwayTeamScore()
        awayTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func rewindScoreItemTapped() {
        
        if let matchViewModel = matchViewModel, let match = matchViewModel.match {
            let rewindScoreViewModel = RewindScoreViewModel(match: match)
            rewindScoreViewModel.delegate = self
            presentControllerWithName("RewindScoreInterfaceController", context: rewindScoreViewModel)
        }
    }
    
    @IBAction func endMenuItemTapped() {
        matchRunningTimeTimer.stop()
        self.clearAllMenuItems()
        
        if let matchViewModel = matchViewModel {
            let reviewMatchViewModel = ReviewMatchViewModel(match: matchViewModel.match!, workoutSessionManager: workoutSessionManager)
            reviewMatchViewModel.delegate = self
            presentControllerWithName("ReviewMatchInterfaceController", context: reviewMatchViewModel)
        }
    }
    
}
