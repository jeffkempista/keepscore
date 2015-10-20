import Foundation
import HealthKit

protocol MatchSetupDelegate: class {
    func matchSetupDidComplete(match: Match, useHealthKit: Bool)
}

class MatchSetupViewModel: NSObject {

    var healthStore: HKHealthStore?
    var activityType: ActivityType
    
    weak var delegate: MatchSetupDelegate?
    
    init(activityType: ActivityType, healthStore: HKHealthStore?) {
        self.activityType = activityType
        self.healthStore = healthStore
    }
    
    dynamic var useHealthKit = false {
        didSet {
            if (useHealthKit) {
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
                    
                    self.healthStore?.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) { success, error in
                        if (success) {
                            let newAuthorizationStatus = self.healthStore?.authorizationStatusForType(HKObjectType.workoutType())
                            if (newAuthorizationStatus == HKAuthorizationStatus.SharingDenied) {
                                self.useHealthKit = false
                            }
                        }
                        if let error = error {
                            debugPrint(error.debugDescription)
                        }
                    }
                }
            }
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
