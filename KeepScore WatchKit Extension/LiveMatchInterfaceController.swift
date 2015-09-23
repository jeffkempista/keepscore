import HealthKit
import WatchKit
import WatchConnectivity
import Foundation

class LiveMatchInterfaceController: WKInterfaceController, WorkoutSessionManagerDelegate, WorkoutSessionContextSetupDelegate {

    @IBOutlet var homeTeamLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamLabel: WKInterfaceLabel!
    @IBOutlet var homeButton: WKInterfaceButton!
    @IBOutlet var awayButton: WKInterfaceButton!
    @IBOutlet var workoutTimer: WKInterfaceTimer!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var distanceTravelledLabel: WKInterfaceLabel!
    
    var workoutSessionManager: WorkoutSessionManager?
    var match = Match(homeTeamName: "Home", awayTeamName: "Away")
    
    var resetScoreInfo = false
    var matchIsInProgress = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateMenu()
        
        if (resetScoreInfo) {
            resetScoreInfo = false
            homeButton.setTitle("-")
            awayButton.setTitle("-")
            workoutTimer.setDate(NSDate())
            distanceTravelledLabel.setText("")
            distanceTravelledLabel.setHidden(true)
            heartRateLabel.setText("")
            heartRateLabel.setHidden(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateMenu() {
        self.clearAllMenuItems()
        if (matchIsInProgress) {
            self.addMenuItemWithItemIcon(.Accept, title: "Save", action: "stopMenuItemTapped")
        } else {
            self.addMenuItemWithItemIcon(.Play, title: "Start", action: "matchSetupMenuItemTapped")
        }
    }

    @IBAction func homeButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.Success)
        match.incrementHomeTeamScore()
        homeButton.setTitle("\(match.homeTeamScore)")
        sendScoreUpdateInfo()
    }

    @IBAction func awayButtonTapped() {
        WKInterfaceDevice.currentDevice().playHaptic(.Success)
        match.incrementAwayTeamScore()
        awayButton.setTitle("\(match.awayTeamScore)")
        sendScoreUpdateInfo()
    }
    
    // MARK: Menu Items
    
    @IBAction func matchSetupMenuItemTapped() {
        self.pushControllerWithName("ActivityListInterfaceController", context: self)
    }
    
    @IBAction func stopMenuItemTapped() {
        self.workoutSessionManager?.stopWorkoutAndSave()
    }
    
    // MARK: WorkoutSessionContextSetupDelegate
    
    func workoutSessionContextSetupComplete(context: WorkoutSessionContext) {
        if let homeTeamName = context.homeTeam, let awayTeamName = context.awayTeam {
            resetScoreInfo = true
            matchIsInProgress = true
            match = Match(homeTeamName: homeTeamName, awayTeamName: awayTeamName)
            self.setTitle("")
            
            self.workoutSessionManager = WorkoutSessionManager(context: context)
            self.workoutSessionManager?.delegate = self
            self.workoutSessionManager?.startWorkout()
        }
    }
    
    // MARK: WorkoutSessionManagerDelegate
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate) {
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
        self.matchIsInProgress = true
        self.workoutTimer.start()
        self.workoutTimer.setHidden(false)
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate) {
        self.matchIsInProgress = false
        self.workoutTimer.stop()
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity) {
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity) {
        let distanceTravelled = distanceQuantity.doubleValueForUnit(HKUnit.meterUnit())
        let distanceTravelledString = NSString(format: "%.2f meters", distanceTravelled) as String
        self.distanceTravelledLabel.setText(distanceTravelledString)
        self.distanceTravelledLabel.setHidden(false)
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample) {
        let heartRate = heartRateSample.quantity.doubleValueForUnit(HKUnit(fromString: "count/min"))
        
        self.heartRateLabel.setText("\(heartRate) beats/min")
        self.heartRateLabel.setHidden(false)
    }
    
    // MARK: WCSession Stuff
    
    func sendScoreUpdateInfo() {
        if (WCSession.defaultSession().reachable) {
            let requestValues = ["type": "ScoreUpdate", "homeTeamScore" : self.match.homeTeamScore, "awayTeamScore": self.match.awayTeamScore] as [String: AnyObject]
            let session = WCSession.defaultSession()
            
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: nil)
        }
    }
    
}
