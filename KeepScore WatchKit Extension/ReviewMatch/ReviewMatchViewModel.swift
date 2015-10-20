import WatchKit

protocol ReviewMatchDelegate: class {
    func matchReviewDidSave(match: Match)
    func matchReviewDidDiscard(match: Match)
}

class ReviewMatchViewModel: NSObject {

    var match: Match
    var workoutSessionManager: WorkoutSessionManager?
    weak var delegate: ReviewMatchDelegate?
    
    init(match: Match, workoutSessionManager: WorkoutSessionManager?) {
        self.match = match
        self.workoutSessionManager = workoutSessionManager
    }
    
    func saveMatch() {
        if let workoutSessionManager = self.workoutSessionManager {
            workoutSessionManager.saveWorkout()
        }
        delegate?.matchReviewDidSave(match)
    }
    
    func discardMatch() {
        delegate?.matchReviewDidDiscard(match)
    }
}
