import HealthKit
import WatchKit
import Foundation

class ActivityListInterfaceController: WKInterfaceController {
    
    let supportedActivities: [HKWorkoutActivityType] = [.Baseball, .Basketball, .Hockey, .Soccer, .TableTennis, .Volleyball]
    let healthStore = HKHealthStore()
    
    var setupDelegate: WorkoutSessionContextSetupDelegate?
    
    @IBOutlet var activityTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let context = context as? WorkoutSessionContextSetupDelegate {
            setupDelegate = context
        }
        setTitle("Cancel")
        loadSupportedActivities()
    }

    override func willActivate() {
        super.willActivate()
        
        let typesToShare = Set([HKObjectType.workoutType()])
        let typesToRead = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
            ])
        
        self.healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) { success, error in
            
        }
    }

    private func loadSupportedActivities() {
        activityTable.setNumberOfRows(supportedActivities.count, withRowType: "ActivityTableRowController")
        
        for (index, activityType) in supportedActivities.enumerate() {
            let row = activityTable.rowControllerAtIndex(index) as! ActivityTableRowController
            row.titleLabel.setText(activityType.getTitle())
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let selectedActitity = supportedActivities[rowIndex]
        
        return WorkoutSessionContext(healthStore: healthStore, activityType: selectedActitity, setupDelegate: setupDelegate)
    }
    
}
