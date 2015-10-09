import HealthKit
import WatchKit
import Foundation

class MatchSetupInterfaceController: WKInterfaceController {

    private var useHealthKitContext = 0
    
    let homeTeams: [WKPickerItem] = [WKPickerItem(title: "Home")]
    let awayTeams: [WKPickerItem] = [WKPickerItem(title: "Away")]
    
    @IBOutlet weak var homeTeamPicker: WKInterfacePicker!
    @IBOutlet weak var awayTeamPicker: WKInterfacePicker!
    @IBOutlet weak var useHealthKitSwitch: WKInterfaceSwitch!
    
    var matchSetupViewModel: MatchSetupViewModel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let matchSetupViewModel = context as? MatchSetupViewModel {
            self.matchSetupViewModel = matchSetupViewModel
            self.setTitle(matchSetupViewModel.activityType.getTitle())
            self.useHealthKitSwitch.setOn(matchSetupViewModel.useHealthKit)
            self.useHealthKitSwitch.setEnabled(matchSetupViewModel.canSelectHealthKit)
        }
        
        self.homeTeamPicker.setItems(homeTeams)
        self.awayTeamPicker.setItems(awayTeams)
        
        self.homeTeamSelected(0)
        self.awayTeamSelected(0)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    
        matchSetupViewModel.addObserver(self, forKeyPath: "useHealthKit", options: .New, context: &useHealthKitContext)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        matchSetupViewModel.removeObserver(self, forKeyPath: "useHealthKit", context: &useHealthKitContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &useHealthKitContext {
            if let newValue = change?[NSKeyValueChangeNewKey] as? Bool {
                useHealthKitSwitch.setOn(newValue)
                useHealthKitSwitch.setEnabled(matchSetupViewModel.canSelectHealthKit)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    @IBAction func homeTeamSelected(value: Int) {
        if let homeTeamName = homeTeams[value].title {
            self.matchSetupViewModel.homeTeamName = homeTeamName
        }
    }
    
    @IBAction func awayTeamSelected(value: Int) {
        if let awayTeamName = awayTeams[value].title {
            self.matchSetupViewModel.awayTeamName = awayTeamName
        }
    }
    
    @IBAction func useHealthKitSwitchChanged(value: Bool) {
        self.matchSetupViewModel.useHealthKit = value
    }
    
    @IBAction func startButtonTapped() {
        debugPrint("startButtonTapped")
        self.matchSetupViewModel.createMatch()
        popToRootController()
    }
    
}
