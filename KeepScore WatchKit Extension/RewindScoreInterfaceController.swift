import WatchKit
import Foundation

class RewindScoreInterfaceController: WKInterfaceController {

    @IBOutlet var matchScorePicker: WKInterfacePicker!
    
    var rewindScoreViewModel: RewindScoreViewModel?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let rewindScoreViewModel = context as? RewindScoreViewModel {
            self.rewindScoreViewModel = rewindScoreViewModel
            populatePicker()
        }
    }

    func populatePicker() {
        if let rewindScoreViewModel = rewindScoreViewModel {
            let matchScorePickerItems = rewindScoreViewModel.matchScores.map({ (matchScore) -> WKPickerItem in
                return WKPickerItem(title: "\(matchScore.homeTeamScore) - \(matchScore.awayTeamScore)")
                
            })
            matchScorePicker.setItems(matchScorePickerItems)
            matchScorePicker.setEnabled(rewindScoreViewModel.matchScorePickerEnabled)
            matchScorePicker.setSelectedItemIndex(rewindScoreViewModel.selectedMatchScoreIndex)
        }
    }
    
    @IBAction func matchScorePickerItemSelected(value: Int) {
        WKInterfaceDevice.currentDevice().playHaptic(.Click)
        rewindScoreViewModel?.selectedMatchScoreIndex = value
    }

    @IBAction func saveButtonTapped() {
        rewindScoreViewModel?.rewindToSelectedMatchScoreIndex()
        dismissController()
    }
    
}
