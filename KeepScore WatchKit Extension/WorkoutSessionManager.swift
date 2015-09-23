import HealthKit

protocol WorkoutSessionManagerDelegate: class {
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate)
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample)
    
}

class WorkoutSessionManager: NSObject, HKWorkoutSessionDelegate {

    let healthStore: HKHealthStore
    let workoutSession: HKWorkoutSession
    
    var workoutActivityType: HKWorkoutActivityType = .Other
    var workoutStartDate: NSDate?
    var workoutEndDate: NSDate?

    var queries: [HKQuery] = []
    
    var activeEnergySamples: [HKQuantitySample] = []
    var distanceSamples: [HKQuantitySample] = []
    var heartRateSamples: [HKQuantitySample] = []
    
    let energyUnit = HKUnit.calorieUnit()
    let distanceUnit = HKUnit.meterUnit()
    let countPerMinuteUnit = HKUnit(fromString: "count/min")
    
    let activeEnergyType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!
    let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    let distanceType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
    
    var currentActiveEnergyQuantity: HKQuantity
    var currentDistanceQuantity: HKQuantity
    var currentHeartRateSample: HKQuantitySample?
    
    weak var delegate: WorkoutSessionManagerDelegate?
    
    init(context: WorkoutSessionContext) {
        self.healthStore = context.healthStore
        self.workoutActivityType = context.activityType
        self.workoutSession = HKWorkoutSession(activityType: workoutActivityType, locationType: context.locationType)
        self.currentActiveEnergyQuantity = HKQuantity(unit: self.energyUnit, doubleValue: 0.0)
        self.currentDistanceQuantity = HKQuantity(unit: self.distanceUnit, doubleValue: 0.0)
        
        super.init()
        
        self.workoutSession.delegate = self
    }
    
    func startWorkout() {
        healthStore.startWorkoutSession(workoutSession)
    }
    
    func stopWorkoutAndSave() {
        healthStore.endWorkoutSession(workoutSession)
    }
    
    // MARK: HKWorkoutSessionDelegate
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        dispatch_async(dispatch_get_main_queue()) {
            switch toState {
            case .Running:
                self.workoutDidStart(date)
            case .Ended:
                self.workoutDidEnd(date)
            default:
                NSLog("Unexpected workout session state \(toState)")
            }
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {

    }
    
    // MARK: Internal
    
    func workoutDidStart(date: NSDate) {
        self.workoutStartDate = date
        
        // Start queries for distance, energy, and heart rate
        queries.append(self.createStreamingActiveEnergyQuery(date))
        queries.append(self.createStreamingDistanceQuery(date))
        queries.append(self.createStreamingHeartRateQuery(date))
        
        for query in queries {
            self.healthStore.executeQuery(query)
        }
        
        self.delegate?.workoutSessionManager(self, didStartWorkoutWithDate: date)
    }
    
    func workoutDidEnd(date: NSDate) {
        self.workoutEndDate = date
        
        // Stop all data queries
        for query in queries {
            self.healthStore.stopQuery(query)
        }
        
        self.queries.removeAll()
        
        self.delegate?.workoutSessionManager(self, didStopWorkoutWithDate: date)
        
        self.saveWorkout()
    }
    
    func saveWorkout() {
        
        guard let startDate = self.workoutStartDate, endDate = self.workoutEndDate else { return }
        // create a workout sample
        let workout = HKWorkout(activityType: self.workoutActivityType, startDate: startDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(startDate), totalEnergyBurned: self.currentActiveEnergyQuantity, totalDistance: self.currentDistanceQuantity, metadata: nil)
        
        // Create an array of all the samples to add to the workout
        var allSamples: [HKQuantitySample] = []
        allSamples += self.activeEnergySamples
        allSamples += self.distanceSamples
        allSamples += self.heartRateSamples
        
        // Save the workout
        self.healthStore.saveObject(workout) { success, error in
            
            if success && allSamples.count > 0 {
                self.healthStore.saveObjects(allSamples, withCompletion: { (success, error) -> Void in
                    
                })
            }
            
        }
    }
    
    // MARK: Data Queries
    
    func createStreamingDistanceQuery(workoutStartDate: NSDate) -> HKQuery {
        // Match samples with the start date after the workout start
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let distanceQuery = HKAnchoredObjectQuery(type: self.distanceType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { (query, samples, deletedSamples, anchor, error) -> Void in
            self.addDistanceSamples(samples)
        }
        
        distanceQuery.updateHandler = {(query, samples, deletedObjects, anchor, error) -> Void in
            self.addDistanceSamples(samples)
        }
        
        return distanceQuery
    }
    
    func addDistanceSamples(samples: [HKSample]?) {
        guard let distanceSamples = samples as? [HKQuantitySample] else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.currentDistanceQuantity = self.currentDistanceQuantity.addQuantitiesFromSamples(distanceSamples, unit: self.distanceUnit)
            self.distanceSamples += distanceSamples
            
            self.delegate?.workoutSessionManager(self, didUpdateDistanceQuantity: self.currentDistanceQuantity)
        }
    }
    
    func createStreamingActiveEnergyQuery(workoutStartDate: NSDate) -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let activeEnergyQuery = HKAnchoredObjectQuery(type: self.activeEnergyType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addActiveEnergySamples(samples)
        }
        
        activeEnergyQuery.updateHandler = {(query, samples, deletedObjects, anchor, error) -> Void in
            self.addActiveEnergySamples(samples)
        }
        
        return activeEnergyQuery
    }
    
    
    func addActiveEnergySamples(samples: [HKSample]?) {
        guard let activeEnergySamples = samples as? [HKQuantitySample] else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.currentActiveEnergyQuantity = self.currentActiveEnergyQuantity.addQuantitiesFromSamples(activeEnergySamples, unit: self.energyUnit)
            self.activeEnergySamples += activeEnergySamples
            
            self.delegate?.workoutSessionManager(self, didUpdateActiveEnergyQuantity: self.currentActiveEnergyQuantity)
        }
    }
    
    func createStreamingHeartRateQuery(workoutStartDate: NSDate) -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let heartRateQuery = HKAnchoredObjectQuery(type: self.heartRateType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) {
            (query, samples, deletedObjects, anchor, error) -> Void in
            self.addHeartRateSamples(samples)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deletedObjects, anchor, error) -> Void in
            self.addHeartRateSamples(samples)
        }
        
        return heartRateQuery
    }
    
    func addHeartRateSamples(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.heartRateSamples += heartRateSamples
            
            if let currentHeartRateSample = self.heartRateSamples.last {
                self.currentHeartRateSample = currentHeartRateSample
                self.delegate?.workoutSessionManager(self, didUpdateHeartRateSample: currentHeartRateSample)
            }
        }
    }
}
