import HealthKit
import WatchKit
import Foundation
import KeepScoreKit

class MatchSetupInterfaceController: WKInterfaceController {

    private var useHealthKitContext = 0
    
    @IBOutlet var useHealthKitSwitch: WKInterfaceSwitch!
    @IBOutlet var startButton: WKInterfaceButton!
    
    var matchSetupViewModel: MatchSetupViewModel?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let matchSetupViewModel = context as? MatchSetupViewModel {
            self.matchSetupViewModel = matchSetupViewModel
            self.setTitle(matchSetupViewModel.activityType.getTitle())
            self.useHealthKitSwitch.setOn(matchSetupViewModel.useHealthKit)
            self.useHealthKitSwitch.setEnabled(matchSetupViewModel.canSelectHealthKit)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    
        matchSetupViewModel?.addObserver(self, forKeyPath: "useHealthKit", options: .New, context: &useHealthKitContext)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        matchSetupViewModel?.removeObserver(self, forKeyPath: "useHealthKit", context: &useHealthKitContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &useHealthKitContext {
            if let newValue = change?[NSKeyValueChangeNewKey] as? Bool, let matchSetupViewModel = matchSetupViewModel {
                useHealthKitSwitch.setOn(newValue)
                useHealthKitSwitch.setEnabled(matchSetupViewModel.canSelectHealthKit)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    @IBAction func useHealthKitSwitchChanged(value: Bool) {
        if let matchSetupViewModel = self.matchSetupViewModel {
            matchSetupViewModel.useHealthKit = value
        }
    }
    
    @IBAction func startButtonTapped() {
        if let matchSetupViewModel = self.matchSetupViewModel {
            matchSetupViewModel.createMatch()
        }
        popToRootController()
    }
    
}
