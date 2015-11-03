import HealthKit

protocol WorkoutSessionManagerDelegate : class {
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate)
}

protocol WorkoutSessionManagerQuantityUpdateDelegate : class {
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample)
    
}

class WorkoutSessionManager: NSObject {

    var healthStore: HKHealthStore
    weak var workoutSession: HKWorkoutSession!
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
    
    var currentActiveEnergyQuantity: HKQuantity = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: 0.0)
    var currentDistanceQuantity: HKQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0.0)
    var currentHeartRateSample: HKQuantitySample?
    
    weak var delegate: WorkoutSessionManagerDelegate?
    weak var quantityUpdateDelegate: WorkoutSessionManagerQuantityUpdateDelegate?
    
    init(healthStore: HKHealthStore, workoutActivityType: HKWorkoutActivityType, workoutSession: HKWorkoutSession) {
        self.healthStore = healthStore
        self.workoutActivityType = workoutActivityType
        self.workoutSession = workoutSession
        
        super.init()
    }
    
    func startWorkout() {
        healthStore.startWorkoutSession(workoutSession)
    }
    
    func stopWorkout() {
        healthStore.endWorkoutSession(workoutSession)
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
        self.delegate?.workoutSessionManager(self, didStopWorkoutWithDate: date)
    }
    
    func saveWorkout() {
        
        guard let startDate = self.workoutStartDate, endDate = self.workoutEndDate else { return }
        // create a workout sample
        debugPrint("saving workout with startDate \(startDate) and endDate \(endDate)")
        debugPrint("saving workout with energy = \(self.currentActiveEnergyQuantity.doubleValueForUnit(self.energyUnit)), distance = \(self.currentDistanceQuantity.doubleValueForUnit(self.distanceUnit))")
        let workout = HKWorkout(activityType: self.workoutActivityType, startDate: startDate, endDate: endDate, duration: endDate.timeIntervalSinceDate(startDate), totalEnergyBurned: self.currentActiveEnergyQuantity, totalDistance: self.currentDistanceQuantity, metadata: nil)
        
        // Create an array of all the samples to add to the workout
        var allSamples: [HKQuantitySample] = []
        allSamples += self.activeEnergySamples
        allSamples += self.distanceSamples
        allSamples += self.heartRateSamples
        
        // Save the workout
        self.healthStore.saveObject(workout) { [weak self] (success, error: NSError?) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let weakSelf = self {
                weakSelf.healthStore.addSamples(allSamples, toWorkout: workout, completion: { (success, error: NSError?) -> Void in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                })
            }
        }
    }
    
    // MARK: Data Queries
    
    func createStreamingDistanceQuery(workoutStartDate: NSDate) -> HKQuery {
        // Match samples with the start date after the workout start
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let distanceQuery = HKAnchoredObjectQuery(type: self.distanceType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedSamples, anchor, error) -> Void in
            self?.addDistanceSamples(samples)
        }
        
        distanceQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addDistanceSamples(samples)
        }
        
        return distanceQuery
    }
    
    func addDistanceSamples(samples: [HKSample]?) {
        guard let distanceSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in distanceSamples {
            debugPrint("Adding Distance Sample \(sample.quantity.doubleValueForUnit(self.distanceUnit))")
        }
        self.currentDistanceQuantity = self.currentDistanceQuantity.addQuantitiesFromSamples(distanceSamples, unit: self.distanceUnit)
        self.distanceSamples += distanceSamples
        self.quantityUpdateDelegate?.workoutSessionManager(self, didUpdateDistanceQuantity: currentDistanceQuantity)
    }
    
    func createStreamingActiveEnergyQuery(workoutStartDate: NSDate) -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let activeEnergyQuery = HKAnchoredObjectQuery(type: self.activeEnergyType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addActiveEnergySamples(samples)
        }
        
        activeEnergyQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addActiveEnergySamples(samples)
        }
        
        return activeEnergyQuery
    }
    
    
    func addActiveEnergySamples(samples: [HKSample]?) {
        guard let activeEnergySamples = samples as? [HKQuantitySample] else { return }
        
        self.currentActiveEnergyQuantity = self.currentActiveEnergyQuantity.addQuantitiesFromSamples(activeEnergySamples, unit: self.energyUnit)
        self.activeEnergySamples += activeEnergySamples
        self.quantityUpdateDelegate?.workoutSessionManager(self, didUpdateActiveEnergyQuantity: self.currentActiveEnergyQuantity)
    }
    
    func createStreamingHeartRateQuery(workoutStartDate: NSDate) -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(workoutStartDate, endDate: nil, options: .None)
        
        let heartRateQuery = HKAnchoredObjectQuery(type: self.heartRateType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addHeartRateSamples(samples)
        }
        
        heartRateQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addHeartRateSamples(samples)
        }
        
        return heartRateQuery
    }
    
    func addHeartRateSamples(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        self.heartRateSamples += heartRateSamples
        if let currentHeartRateSample = self.heartRateSamples.last {
            self.currentHeartRateSample = currentHeartRateSample
            self.quantityUpdateDelegate?.workoutSessionManager(self,didUpdateHeartRateSample: currentHeartRateSample)
        }
    }
    
}
