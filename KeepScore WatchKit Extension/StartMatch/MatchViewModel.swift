import Foundation
import HealthKit
import WatchConnectivity

class MatchViewModel: NSObject, MatchSetupDelegate, WorkoutSessionManagerDelegate {

    var healthStore = HKHealthStore()
    var workoutSessionManager: WorkoutSessionManager?
    dynamic var matchInProgress = false
    var match: Match?
    var startDate: NSDate?
    var useHealthKit = false
    dynamic var distanceTravelled: Double = 0.0
    dynamic var caloriesBurned: Double = 0.0
    dynamic var heartRate: Double = 0.0
    
    var matchSetupRequired: Bool {
        return match == nil
    }
    
    var distanceTravelledForDisplay: String {
        let distanceTravelledString = NSString(format: "%.2f meters", distanceTravelled) as String
        return distanceTravelledString
    }
    
    var heartRateForDisplay: String {
        return "\(heartRate) beats/min"
    }
    
    var caloriesBurnedForDisplay: String {
        return "\(caloriesBurned) cal"
    }

    func setupMatch() -> MatchSetupViewModel {
        let matchSetupViewModel = MatchSetupViewModel(healthStore: healthStore)
        matchSetupViewModel.delegate = self
        return matchSetupViewModel
    }

    func matchSetupDidComplete(matchSetupViewModel: MatchSetupViewModel) {
        self.matchInProgress = true

        let match = Match(activityType: matchSetupViewModel.activityType, homeTeamName: matchSetupViewModel.homeTeamName, awayTeamName: matchSetupViewModel.awayTeamName)
        self.match = match
        self.useHealthKit = matchSetupViewModel.useHealthKit
        
        if (self.useHealthKit) {
            let workoutSessionManager = WorkoutSessionManager(healthStore: self.healthStore, workoutActivityType: match.activityType.getWorkoutActivityType(), locationType: .Unknown)
            self.workoutSessionManager = workoutSessionManager
            workoutSessionManager.delegate = self
            workoutSessionManager.startWorkout()
        } else {
            self.startDate = NSDate()
        }
        sendScoreUpdateInfo()
    }
    
    func incrementHomeTeamScore() -> Int {
        guard let match = match else {
            return 0
        }
        match.incrementHomeTeamScore()
        sendScoreUpdateInfo()
        return match.homeTeamScore
    }
    
    func incrementAwayTeamScore() -> Int {
        guard let match = match else {
            return 0
        }
        match.incrementAwayTeamScore()
        sendScoreUpdateInfo()
        return match.awayTeamScore
    }
    
    func endMatch() -> ReviewMatchViewModel? {
        self.matchInProgress = false
        workoutSessionManager?.stopWorkout()
        guard let match = match else {
            return nil
        }
        
        let reviewMatchViewModel = ReviewMatchViewModel(match: match, workoutSessionManager: workoutSessionManager)
        
        sendScoreUpdateInfo()
        
        return reviewMatchViewModel
    }
    
    // MARK: WCSession Stuff
    
    func sendScoreUpdateInfo() {
        if let match = self.match where WCSession.defaultSession().reachable {
            let requestValues = ["type": "ScoreUpdate", "homeTeamScore" : match.homeTeamScore, "awayTeamScore": match.awayTeamScore] as [String: AnyObject]
            let session = WCSession.defaultSession()
            
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: nil)
        }
    }
    
    // MARK: Workout Session Manager Delegate
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate) {
        debugPrint("workoutSessionManager-didStartWorkoutWithDate \(startDate)")
        self.startDate = startDate
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate) {
        debugPrint("workoutSessionManager-didStopWorkoutWithDate \(endDate)")
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity) {
        caloriesBurned = activeEnergyQuantity.doubleValueForUnit(workoutSessionManager.energyUnit)
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity) {
        distanceTravelled = distanceQuantity.doubleValueForUnit(workoutSessionManager.distanceUnit)
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample) {
        heartRate = heartRateSample.quantity.doubleValueForUnit(workoutSessionManager.countPerMinuteUnit)
    }
    
}
