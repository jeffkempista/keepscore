import Foundation
import HealthKit
import KeepScoreKit

class MatchViewModel: NSObject, WorkoutSessionManagerDelegate, WorkoutSessionManagerQuantityUpdateDelegate, HKWorkoutSessionDelegate {

    var match: Match?
    var useHealthKit = false
    weak var workoutSessionManager: WorkoutSessionManager?
    dynamic var startDate: Date?
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
        return match.homeTeamScore
    }
    
    func incrementAwayTeamScore() -> Int {
        guard let match = match else {
            return 0
        }
        match.incrementAwayTeamScore()
        return match.awayTeamScore
    }
    
    func startMatch() {
        if let workoutSessionManager = workoutSessionManager {
            workoutSessionManager.startWorkout()
        } else {
            startDate = Date()
        }
    }
    
    func endMatch() {
        if let workoutSessionManager = workoutSessionManager {
            workoutSessionManager.stopWorkout()
        }
        
    }
    
    // MARK: Workout Session Manager Delegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        DispatchQueue.main.async { [weak self] in
            switch toState {
            case .running:
                self?.workoutSessionManager?.workoutDidStart(date)
            case .ended:
                self?.workoutSessionManager?.workoutDidEnd(date)
            default:
                NSLog("Unexpected workout session state \(toState)")
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: Date) {
        self.startDate = startDate
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: Date) {
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity) {
        caloriesBurned = activeEnergyQuantity.doubleValue(for: workoutSessionManager.energyUnit)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity) {
        distanceTravelled = distanceQuantity.doubleValue(for: workoutSessionManager.distanceUnit)
    }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample) {
        heartRate = heartRateSample.quantity.doubleValue(for: workoutSessionManager.countPerMinuteUnit)
    }
    
}
