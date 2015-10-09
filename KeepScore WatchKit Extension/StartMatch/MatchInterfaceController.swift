import WatchKit
import Foundation

class MatchInterfaceController: WKInterfaceController {
    
    private var heartRateContext = 0
    private var distanceTravelledContext = 0
    private var caloriesBurnedContext = 0
    
    @IBOutlet var startMatchGroup: WKInterfaceGroup!
    @IBOutlet var scoreMatchGroup: WKInterfaceGroup!
    @IBOutlet var homeTeamScoreButton: WKInterfaceButton!
    @IBOutlet var awayTeamScoreButton: WKInterfaceButton!
    @IBOutlet var matchRunningTimeTimer: WKInterfaceTimer!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var distanceTravelledLabel: WKInterfaceLabel!
    
    var matchViewModel = MatchViewModel()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        debugPrint("MatchInterfaceController - awakeWithContext")
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        debugPrint("MatchInterfaceController - willActivate")
        
        startMatchGroup.setHidden(matchViewModel.matchInProgress)
        scoreMatchGroup.setHidden(!matchViewModel.matchInProgress)
        if (matchViewModel.matchSetupRequired) {
            setupMatch()
        }
        addObservers()
    }
    
    override func didAppear() {
        super.didAppear()
        debugPrint("MatchInterfaceController - didAppear")
        
        if (matchViewModel.matchSetupRequired) {
            setupMatch()
        }
        
        if let startDate = matchViewModel.startDate {
            matchRunningTimeTimer.setDate(startDate)
            matchRunningTimeTimer.setHidden(false)
            matchRunningTimeTimer.start()
        }
        updateMenu()
    }
    
    override func willDisappear() {
        super.willDisappear()
        debugPrint("MatchInterfaceController - willDisappear")
    }

    override func didDeactivate() {
        super.didDeactivate()
        debugPrint("MatchInterfaceController - didDeactivate")
        
        removeObservers()
    }
    
    func addObservers() {
        if (matchViewModel.matchInProgress) {
            matchViewModel.addObserver(self, forKeyPath: "distanceTravelled", options: .New, context: &distanceTravelledContext)
            matchViewModel.addObserver(self, forKeyPath: "heartRate", options: .New, context: &heartRateContext)
            matchViewModel.addObserver(self, forKeyPath: "caloriesBurned", options: .New, context: &caloriesBurnedContext)
        }
    }
    
    func removeObservers() {
        if (matchViewModel.matchInProgress) {
            matchViewModel.removeObserver(self, forKeyPath: "distanceTravelled", context: &distanceTravelledContext)
            matchViewModel.removeObserver(self, forKeyPath: "heartRate", context: &heartRateContext)
            matchViewModel.removeObserver(self, forKeyPath: "caloriesBurned", context: &caloriesBurnedContext)
        }
    }
    
    func updateMenu() {
        self.clearAllMenuItems()
        if (matchViewModel.matchInProgress) {
            self.addMenuItemWithItemIcon(.Decline, title: "End", action: "endMenuItemTapped")
        }
    }
    
    func setupMatch() {
        homeTeamScoreButton.setTitle("-")
        awayTeamScoreButton.setTitle("-")
        heartRateLabel.setText("")
        distanceTravelledLabel.setText("")
        
        let matchSetupViewModel = matchViewModel.setupMatch()
        pushControllerWithName("ActivityListInterfaceController", context: matchSetupViewModel)
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch (context) {
        case &distanceTravelledContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? Double where newValue > 0.0 {
                distanceTravelledLabel.setText(matchViewModel.distanceTravelledForDisplay)
                distanceTravelledLabel.setHidden(!matchViewModel.matchInProgress && !matchViewModel.useHealthKit)
            }
        case &heartRateContext:
            if let newValue = change?[NSKeyValueChangeNewKey] as? Double where newValue > 0.0 {
                heartRateLabel.setText(matchViewModel.heartRateForDisplay)
                heartRateLabel.setHidden(!matchViewModel.matchInProgress && !matchViewModel.useHealthKit)
            }
        default:
            break;
        }
    }
    
    // MARK: Interface Actions
    
    @IBAction func startMatchButtonTapped() {
        let matchSetupViewModel = matchViewModel.setupMatch()
        pushControllerWithName("ActivityListInterfaceController", context: matchSetupViewModel)
    }
    
    @IBAction func homeTeamScoreButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.DirectionUp)
        let newScore = matchViewModel.incrementHomeTeamScore()
        homeTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func awayTeamScoreButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.DirectionDown)
        let newScore = matchViewModel.incrementAwayTeamScore()
        awayTeamScoreButton.setTitle("\(newScore)")
    }
    
    @IBAction func endMenuItemTapped() {
        matchRunningTimeTimer.stop()
        self.clearAllMenuItems()
        removeObservers()
        if let reviewMatchViewModel = matchViewModel.endMatch() {
            self.matchViewModel = MatchViewModel()
            presentControllerWithName("ReviewMatchInterfaceController", context: reviewMatchViewModel)
        }
    }

}
