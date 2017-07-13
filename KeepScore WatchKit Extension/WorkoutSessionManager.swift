import HealthKit

protocol WorkoutSessionManagerDelegate : class {
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStartWorkoutWithDate startDate: Date)
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didStopWorkoutWithDate endDate: Date)
}

protocol WorkoutSessionManagerQuantityUpdateDelegate : class {
    
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateActiveEnergyQuantity activeEnergyQuantity: HKQuantity)
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateDistanceQuantity distanceQuantity: HKQuantity)
    func workoutSessionManager(_ workoutSessionManager: WorkoutSessionManager, didUpdateHeartRateSample heartRateSample: HKQuantitySample)
    
}

class WorkoutSessionManager: NSObject {

    var healthStore: HKHealthStore
    weak var workoutSession: HKWorkoutSession!
    var workoutActivityType: HKWorkoutActivityType = .other
    
    var workoutStartDate: Date?
    var workoutEndDate: Date?

    var queries: [HKQuery] = []
    
    var activeEnergySamples: [HKQuantitySample] = []
    var distanceSamples: [HKQuantitySample] = []
    var heartRateSamples: [HKQuantitySample] = []
    
    let energyUnit = HKUnit.calorie()
    let distanceUnit = HKUnit.meter()
    let countPerMinuteUnit = HKUnit(from: "count/min")
    
    let activeEnergyType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
    let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let distanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
    
    var currentActiveEnergyQuantity: HKQuantity = HKQuantity(unit: HKUnit.calorie(), doubleValue: 0.0)
    var currentDistanceQuantity: HKQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: 0.0)
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
        healthStore.start(workoutSession)
    }
    
    func stopWorkout() {
        healthStore.end(workoutSession)
    }
        
    // MARK: Internal
    
    func workoutDidStart(_ date: Date) {
        self.workoutStartDate = date
        
        // Start queries for distance, energy, and heart rate
        queries.append(self.createStreamingActiveEnergyQuery(date))
        queries.append(self.createStreamingDistanceQuery(date))
        queries.append(self.createStreamingHeartRateQuery(date))
        
        for query in queries {
            self.healthStore.execute(query)
        }
     
        self.delegate?.workoutSessionManager(self, didStartWorkoutWithDate: date)
    }
    
    func workoutDidEnd(_ date: Date) {
        self.workoutEndDate = date
        self.delegate?.workoutSessionManager(self, didStopWorkoutWithDate: date)
    }
    
    func saveWorkout() {
        
        guard let startDate = self.workoutStartDate, let endDate = self.workoutEndDate else { return }
        // create a workout sample
        debugPrint("saving workout with startDate \(startDate) and endDate \(endDate)")
        debugPrint("saving workout with energy = \(self.currentActiveEnergyQuantity.doubleValue(for: self.energyUnit)), distance = \(self.currentDistanceQuantity.doubleValue(for: self.distanceUnit))")
        let workout = HKWorkout(activityType: self.workoutActivityType, start: startDate, end: endDate, duration: endDate.timeIntervalSince(startDate), totalEnergyBurned: self.currentActiveEnergyQuantity, totalDistance: self.currentDistanceQuantity, metadata: nil)
        
        // Create an array of all the samples to add to the workout
        var allSamples: [HKQuantitySample] = []
        allSamples += self.activeEnergySamples
        allSamples += self.distanceSamples
        allSamples += self.heartRateSamples
        
        // Save the workout
        self.healthStore.save(workout) { [weak self] (success, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let weakSelf = self {
                weakSelf.healthStore.add(allSamples, to: workout, completion: { (success, error) -> Void in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                })
            }
        }
    }
    
    // MARK: Data Queries
    
    func createStreamingDistanceQuery(_ workoutStartDate: Date) -> HKQuery {
        // Match samples with the start date after the workout start
        let predicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: HKQueryOptions())
        
        let distanceQuery = HKAnchoredObjectQuery(type: self.distanceType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedSamples, anchor, error) -> Void in
            self?.addDistanceSamples(samples)
        }
        
        distanceQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addDistanceSamples(samples)
        }
        
        return distanceQuery
    }
    
    func addDistanceSamples(_ samples: [HKSample]?) {
        guard let distanceSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in distanceSamples {
            debugPrint("Adding Distance Sample \(sample.quantity.doubleValue(for: self.distanceUnit))")
        }
        self.currentDistanceQuantity = self.currentDistanceQuantity.addQuantitiesFromSamples(distanceSamples, unit: self.distanceUnit)
        self.distanceSamples += distanceSamples
        self.quantityUpdateDelegate?.workoutSessionManager(self, didUpdateDistanceQuantity: currentDistanceQuantity)
    }
    
    func createStreamingActiveEnergyQuery(_ workoutStartDate: Date) -> HKQuery {
        let predicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: HKQueryOptions())
        
        let activeEnergyQuery = HKAnchoredObjectQuery(type: self.activeEnergyType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addActiveEnergySamples(samples)
        }
        
        activeEnergyQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addActiveEnergySamples(samples)
        }
        
        return activeEnergyQuery
    }
    
    
    func addActiveEnergySamples(_ samples: [HKSample]?) {
        guard let activeEnergySamples = samples as? [HKQuantitySample] else { return }
        
        self.currentActiveEnergyQuantity = self.currentActiveEnergyQuantity.addQuantitiesFromSamples(activeEnergySamples, unit: self.energyUnit)
        self.activeEnergySamples += activeEnergySamples
        self.quantityUpdateDelegate?.workoutSessionManager(self, didUpdateActiveEnergyQuantity: self.currentActiveEnergyQuantity)
    }
    
    func createStreamingHeartRateQuery(_ workoutStartDate: Date) -> HKQuery {
        let predicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: HKQueryOptions())
        
        let heartRateQuery = HKAnchoredObjectQuery(type: self.heartRateType, predicate: predicate, anchor: HKQueryAnchor(fromValue: 0), limit: 0) { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addHeartRateSamples(samples)
        }
        
        heartRateQuery.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) -> Void in
            self?.addHeartRateSamples(samples)
        }
        
        return heartRateQuery
    }
    
    func addHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        self.heartRateSamples += heartRateSamples
        if let currentHeartRateSample = self.heartRateSamples.last {
            self.currentHeartRateSample = currentHeartRateSample
            self.quantityUpdateDelegate?.workoutSessionManager(self,didUpdateHeartRateSample: currentHeartRateSample)
        }
    }
    
}
