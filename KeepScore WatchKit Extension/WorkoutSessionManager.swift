import HealthKit

protocol WorkoutSessionManagerDelegate : HKWorkoutSessionDelegate {
    
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: NSDate)
    func workoutSessionManager(workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: NSDate)
    
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
        
        self.delegate?.workoutSessionManager(self, didStopWorkoutWithDate: date)
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
        self.healthStore.saveObject(workout) { [weak self] success, error in
            if (!success) {
                debugPrint(error?.localizedDescription)
            }
            
            if success && allSamples.count > 0 {
                self?.healthStore.saveObjects(allSamples, withCompletion: { (success, error) -> Void in
                    if let error = error as NSError? {
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
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            if let weakSelf = self {
                weakSelf.currentDistanceQuantity = weakSelf.currentDistanceQuantity.addQuantitiesFromSamples(distanceSamples, unit: weakSelf.distanceUnit)
                weakSelf.distanceSamples += distanceSamples
                
                weakSelf.delegate?.workoutSessionManager(weakSelf, didUpdateDistanceQuantity: weakSelf.currentDistanceQuantity)
            }
        }
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
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            if let weakSelf = self {
                weakSelf.currentActiveEnergyQuantity = weakSelf.currentActiveEnergyQuantity.addQuantitiesFromSamples(activeEnergySamples, unit: weakSelf.energyUnit)
                weakSelf.activeEnergySamples += activeEnergySamples
                
                weakSelf.delegate?.workoutSessionManager(weakSelf, didUpdateActiveEnergyQuantity: weakSelf.currentActiveEnergyQuantity)
            }
        }
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
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
            if let weakSelf = self {
                weakSelf.heartRateSamples += heartRateSamples
                
                if let currentHeartRateSample = weakSelf.heartRateSamples.last {
                    weakSelf.currentHeartRateSample = currentHeartRateSample
                    weakSelf.delegate?.workoutSessionManager(weakSelf, didUpdateHeartRateSample: currentHeartRateSample)
                }
            }
        }
    }
    
}
