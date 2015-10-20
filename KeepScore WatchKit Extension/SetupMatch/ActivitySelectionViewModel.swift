import WatchKit

class ActivitySelectionViewModel: NSObject {

    private let _supportedActivities: [ActivityType] = [.Baseball, .Basketball, .Hockey, .Soccer, .TableTennis, .Volleyball]
 
    var selectedActivityType = ActivityType.Other
    
    var supportedActivities: [ActivityType] {
        get {
            return _supportedActivities
        }
    }
    
}
