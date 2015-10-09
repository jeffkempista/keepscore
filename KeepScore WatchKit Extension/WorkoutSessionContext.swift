import HealthKit
import Foundation

protocol WorkoutSessionContextSetupDelegate {
    
    func workoutSessionContextSetupComplete(context: WorkoutSessionContext);
    
}

class WorkoutSessionContext : NSObject {
    
    let healthStore: HKHealthStore
    var activityType: HKWorkoutActivityType
    var locationType: HKWorkoutSessionLocationType
    var setupDelegate: WorkoutSessionContextSetupDelegate?
    
    var homeTeam: String?
    var awayTeam: String?
    
    init(healthStore: HKHealthStore, activityType: HKWorkoutActivityType = .Other, locationType: HKWorkoutSessionLocationType = .Unknown, setupDelegate: WorkoutSessionContextSetupDelegate?) {
        
        self.healthStore = healthStore
        self.activityType = activityType
        self.locationType = locationType
        self.setupDelegate = setupDelegate
    }

}
