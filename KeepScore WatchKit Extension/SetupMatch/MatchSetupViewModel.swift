import Foundation
import HealthKit

protocol MatchSetupDelegate: class {
    func matchSetupDidComplete(match: Match, useHealthKit: Bool)
}

class MatchSetupViewModel: NSObject {

    private let useHealthKitKey = "useHealthKit"
    
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
                } else if (hkAuthorizationStatus == .NotDetermined) {
                    
                    let typesToShare = Set([HKObjectType.workoutType()])
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
                            }
                        }
                        if let error = error {
                            debugPrint(error.debugDescription)
                        }
                    }
                }
            }
            NSUserDefaults.standardUserDefaults().setBool(useHealthKit, forKey: useHealthKitKey)
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
