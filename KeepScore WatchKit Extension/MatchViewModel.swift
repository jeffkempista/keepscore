import Foundation
import HealthKit
import WatchConnectivity
import KeepScoreKit

class MatchViewModel: NSObject, WorkoutSessionManagerDelegate, WorkoutSessionManagerQuantityUpdateDelegate, HKWorkoutSessionDelegate {

    var match: Match?
    var useHealthKit = false
    weak var workoutSessionManager: WorkoutSessionManager?
    dynamic var startDate: NSDate?
    dynamic var distanceTravelled: Double = 0.0
    dynamic var caloriesBurned: Double = 0.0
    dynamic var heartRate: Double = 0.0
    
    init(match: Match, useHealthKit: Bool, workoutSessionManager: WorkoutSessionManager?) {
        
        self.match = match
        self.useHealthKit = useHealthKit
        self.workoutSessionManager = workoutSessionManager

        super.init()
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
    
    func startMatch() {
        if let workoutSessionManager = workoutSessionManager {
            workoutSessionManager.startWorkout()
        } else {
            startDate = NSDate()
        }
        
        sendScoreUpdateInfo()
    }
    
    func endMatch() {
        if let workoutSessionManager = workoutSessionManager {
            workoutSessionManager.stopWorkout()
        }
        sendScoreUpdateInfo()
    }
    
    // MARK: Workout Session Manager Delegate
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            switch toState {
            case .Running:
                self?.workoutSessionManager?.workoutDidStart(date)
            case .Ended:
                self?.workoutSessionManager?.workoutDidEnd(date)
            default:
                NSLog("Unexpected workout session state \(toState)")
            }
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate) {
        self.startDate = startDate
    }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate) {
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
    
    // MARK: WCSession Stuff
    
    func sendScoreUpdateInfo() {
        if let match = self.match where WCSession.defaultSession().reachable {
            let requestValues = ["type": "ScoreUpdate", "homeTeamScore" : match.homeTeamScore, "awayTeamScore": match.awayTeamScore] as [String: AnyObject]
            let session = WCSession.defaultSession()
            
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: nil)
        }
    }
    
}
