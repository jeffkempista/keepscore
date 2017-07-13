import HealthKit
import WatchKit
import Foundation
import KeepScoreKit

class MatchSetupInterfaceController: WKInterfaceController {

    fileprivate var useHealthKitContext = 0
    
    @IBOutlet var useHealthKitSwitch: WKInterfaceSwitch!
    @IBOutlet var startButton: WKInterfaceButton!
    
    var matchSetupViewModel: MatchSetupViewModel?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
    
        matchSetupViewModel?.addObserver(self, forKeyPath: "useHealthKit", options: .new, context: &useHealthKitContext)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        matchSetupViewModel?.removeObserver(self, forKeyPath: "useHealthKit", context: &useHealthKitContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &useHealthKitContext {
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? Bool, let matchSetupViewModel = matchSetupViewModel {
                useHealthKitSwitch.setOn(newValue)
                useHealthKitSwitch.setEnabled(matchSetupViewModel.canSelectHealthKit)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @IBAction func useHealthKitSwitchChanged(_ value: Bool) {
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
