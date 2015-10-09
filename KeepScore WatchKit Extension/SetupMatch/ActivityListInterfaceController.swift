import HealthKit
import WatchKit
import Foundation

class ActivityListInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var activityTable: WKInterfaceTable!
    
    var matchSetupViewModel: MatchSetupViewModel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let matchSetupViewModel = context as? MatchSetupViewModel {
            self.matchSetupViewModel = matchSetupViewModel
            loadSupportedActivities()
        }
    }

    override func willActivate() {
        super.willActivate()
    }

    private func loadSupportedActivities() {
        activityTable.setNumberOfRows(matchSetupViewModel.supportedActivities.count, withRowType: "ActivityTableRowController")
        
        for (index, activityType) in matchSetupViewModel.supportedActivities.enumerate() {
            let row = activityTable.rowControllerAtIndex(index) as! ActivityTableRowController
            row.titleLabel.setText(activityType.getTitle())
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        let selectedActitity = matchSetupViewModel.supportedActivities[rowIndex]
        matchSetupViewModel.activityType = selectedActitity
        
        return matchSetupViewModel
    }
    
}
