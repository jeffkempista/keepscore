import Foundation
import HealthKit
import KeepScoreKit

protocol MatchSetupDelegate: class {
    func matchSetupDidComplete(match: Match, useHealthKit: Bool)
}

private let useHealthKitKey = "useHealthKit"

class MatchSetupViewModel: NSObject {
    
    var healthStore: HKHealthStore?
    var activityType: ActivityType
    
    weak var delegate: MatchSetupDelegate?
    
    init(activityType: ActivityType, healthStore: HKHealthStore?) {
        self.activityType = activityType
        self.healthStore = healthStore
        self.useHealthKit = NSUserDefaults.standardUserDefaults().boolForKey(useHealthKitKey)
    }
    
    dynamic var useHealthKit = false {
        didSet {
            if useHealthKit {
                let hkAuthorizationStatus = healthStore?.authorizationStatusForType(HKObjectType.workoutType())
                if (hkAuthorizationStatus == .SharingDenied) {
                    useHealthKit = false
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: useHealthKitKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                } else if (hkAuthorizationStatus == .NotDetermined) {
                    
                    let typesToShare = Set([
                        HKObjectType.workoutType(),
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
                        ])
                    let typesToRead = Set([
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
                        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
                        ])
                    
                    self.healthStore?.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) { [weak self] success, error in
                        if let weakSelf = self where success {
                            let newAuthorizationStatus = weakSelf.healthStore?.authorizationStatusForType(HKObjectType.workoutType())
                            if (newAuthorizationStatus == HKAuthorizationStatus.SharingDenied) {
                                weakSelf.useHealthKit = false
                                NSUserDefaults.standardUserDefaults().setBool(false, forKey: useHealthKitKey)
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                        }
                        if let error = error {
                            debugPrint(error.debugDescription)
                        }
                    }
                }
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: useHealthKitKey)
        }
    }
    
    dynamic var canSelectHealthKit: Bool {
        get {
            return healthStore?.authorizationStatusForType(HKObjectType.workoutType()) != .SharingDenied
        }
    }
    
    func createMatch() {
        if let delegate = delegate {
            let match = Match(activityType: self.activityType, homeTeamName: "Home", awayTeamName: "Away")
            delegate.matchSetupDidComplete(match, useHealthKit: self.useHealthKit)
        }
    }
    
}
