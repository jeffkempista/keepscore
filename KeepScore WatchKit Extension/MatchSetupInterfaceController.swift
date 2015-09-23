import HealthKit
import WatchKit
import Foundation

class MatchSetupInterfaceController: WKInterfaceController {

    let homeTeams: [WKPickerItem] = [WKPickerItem(title: "Home"), WKPickerItem(title: "Light Shirts"), WKPickerItem(title: "Shirts"), WKPickerItem(title: "LIV")]
    let awayTeams: [WKPickerItem] = [WKPickerItem(title: "Away"), WKPickerItem(title: "Dark Shirts"), WKPickerItem(title: "Skins"), WKPickerItem(title: "MUN")]
    
    @IBOutlet var homeTeamPicker: WKInterfacePicker!
    @IBOutlet var awayTeamPicker: WKInterfacePicker!
    
    var workoutSession: WorkoutSessionContext!
    var selectedHomeTeam: String?
    var selectedAwayTeam: String?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let workoutSession = context as? WorkoutSessionContext {
            self.workoutSession = workoutSession
            self.setTitle(workoutSession.activityType.getTitle())
        }
        
        self.homeTeamPicker.setItems(homeTeams)
        self.awayTeamPicker.setItems(awayTeams)
        
        self.homeTeamSelected(0)
        self.awayTeamSelected(0)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func homeTeamSelected(value: Int) {
        self.selectedHomeTeam = homeTeams[value].title
    }
    
    @IBAction func awayTeamSelected(value: Int) {
        self.selectedAwayTeam = awayTeams[value].title
    }
    
    @IBAction func startButtonTapped() {
        self.workoutSession.homeTeam = self.selectedHomeTeam
        self.workoutSession.awayTeam = self.selectedAwayTeam
        
        self.workoutSession.setupDelegate?.workoutSessionContextSetupComplete(self.workoutSession)
        self.popToRootController()
    }
    
}
