import WatchKit

class ReviewMatchViewModel: NSObject {

    var match: Match
    var workoutSessionManager: WorkoutSessionManager?
    
    init(match: Match, workoutSessionManager: WorkoutSessionManager?) {
        self.match = match
        self.workoutSessionManager = workoutSessionManager
    }
    
    func saveMatch() {
        if let workoutSessionManager = self.workoutSessionManager {
            workoutSessionManager.saveWorkout()
        }
    }
    
}
