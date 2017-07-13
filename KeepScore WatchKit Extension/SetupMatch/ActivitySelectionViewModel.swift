import Foundation
import KeepScoreKit

class ActivitySelectionViewModel: NSObject {

    fileprivate let _supportedActivities: [ActivityType] = [.Baseball, .Basketball, .Hockey, .Soccer, .TableTennis, .Volleyball, .Other]
 
    var selectedActivityType = ActivityType.Other
    
    var supportedActivities: [ActivityType] {
        get {
            return _supportedActivities
        }
    }
    
}
