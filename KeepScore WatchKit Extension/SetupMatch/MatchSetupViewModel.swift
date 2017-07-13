import Foundation
import HealthKit
import KeepScoreKit

protocol MatchSetupDelegate: class {
    func matchSetupDidComplete(_ match: Match, useHealthKit: Bool)
}

private let useHealthKitKey = "useHealthKit"

class MatchSetupViewModel: NSObject {
    
    var healthStore: HKHealthStore?
    var activityType: ActivityType
    
    weak var delegate: MatchSetupDelegate?
    
    init(activityType: ActivityType, healthStore: HKHealthStore?) {
        self.activityType = activityType
        self.healthStore = healthStore
        self.useHealthKit = UserDefaults.standard.bool(forKey: useHealthKitKey)
    }
    
    dynamic var useHealthKit = false {
        didSet {
            if useHealthKit {
                let hkAuthorizationStatus = healthStore?.authorizationStatus(for: HKObjectType.workoutType())
                if (hkAuthorizationStatus == .sharingDenied) {
                    useHealthKit = false
                    UserDefaults.standard.set(false, forKey: useHealthKitKey)
                    UserDefaults.standard.synchronize()
                } else if (hkAuthorizationStatus == .notDetermined) {
                    
                    let typesToShare = Set([
                        HKObjectType.workoutType(),
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
                        ])
                    let typesToRead = Set([
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
                        ])
                    
                    self.healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
                        if let weakSelf = self, success {
                            let newAuthorizationStatus = weakSelf.healthStore?.authorizationStatus(for: HKObjectType.workoutType())
                            if (newAuthorizationStatus == HKAuthorizationStatus.sharingDenied) {
                                weakSelf.useHealthKit = false
                                UserDefaults.standard.set(false, forKey: useHealthKitKey)
                                UserDefaults.standard.synchronize()
                            }
                        }
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
            }
            UserDefaults.standard.set(true, forKey: useHealthKitKey)
        }
    }
    
    dynamic var canSelectHealthKit: Bool {
        get {
            return healthStore?.authorizationStatus(for: HKObjectType.workoutType()) != .sharingDenied
        }
    }
    
    func createMatch() {
        if let delegate = delegate {
            let match = Match(activityType: self.activityType, homeTeamName: "Home", awayTeamName: "Away")
            delegate.matchSetupDidComplete(match, useHealthKit: self.useHealthKit)
        }
    }
    
}
