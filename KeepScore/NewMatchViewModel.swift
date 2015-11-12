import Foundation
import KeepScoreKit

class NewMatchViewModel: NSObject {

    var activityPickerVisible = false
    let supportedActivities: [ActivityType] = [.Baseball, .Basketball, .Hockey, .Soccer, .TableTennis, .Volleyball, .Other]
    
    var selectedActivityIndex = 3
    var selectedActivityLabelText: String {
        get {
            return supportedActivities[selectedActivityIndex].getTitle()
        }
    }
    var homeTeamName = ""
    var awayTeamName = ""
 
    var startButtonEnabled: Bool {
        get {
            return homeTeamName.utf16.count > 0 && awayTeamName.utf16.count > 0
        }
    }
    
    func startMatch() -> Match {
        let activityType = supportedActivities[selectedActivityIndex]
        let match = Match(activityType: activityType, homeTeamName: homeTeamName, awayTeamName: awayTeamName)
        return match
    }
    
}
