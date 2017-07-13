import Foundation
import KeepScoreKit

protocol ReviewMatchDelegate: class {
    func matchReviewDidSave(_ match: Match)
    func matchReviewDidDiscard(_ match: Match)
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
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: Date) { }
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: Date) {
        if (saveWorkout) {
            saveWorkout = false
            workoutSessionManager.saveWorkout()
            matchConnectivityManager.saveMatch(match)
        }
        delegate?.matchReviewDidSave(match)
    }
    
    
}
