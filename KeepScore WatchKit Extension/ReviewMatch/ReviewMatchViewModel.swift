import Foundation
import KeepScoreKit

protocol ReviewMatchDelegate: class {
    func matchReviewDidSave(match: Match)
    func matchReviewDidDiscard(match: Match)
}

class ReviewMatchViewModel: NSObject, WorkoutSessionManagerDelegate {

    let matchConnectivityManager = MatchConnectivityManager()
    var match: Match
    var workoutSessionManager: WorkoutSessionManager?
    var saveWorkout = false
    weak var delegate: ReviewMatchDelegate?
    
    init(match: Match, workoutSessionManager: WorkoutSessionManager?) {
        self.match = match
        self.workoutSessionManager = workoutSessionManager
    }
    
    func saveMatch() {
        if let workoutSessionManager = self.workoutSessionManager {
            saveWorkout = true
            workoutSessionManager.delegate = self
            workoutSessionManager.stopWorkout()
        } else {
            matchConnectivityManager.saveMatch(match)
            delegate?.matchReviewDidSave(match)
        }
    }
    
    func discardMatch() {
        workoutSessionManager?.stopWorkout()
        delegate?.matchReviewDidDiscard(match)
    }
    
    // MARK: Workout Session Manager Delegate
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate) { }
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate) {
        if (saveWorkout) {
            saveWorkout = false
            workoutSessionManager.saveWorkout()
            matchConnectivityManager.saveMatch(match)
        }
        delegate?.matchReviewDidSave(match)
    }
    
    
}
