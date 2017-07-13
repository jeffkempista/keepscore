import WatchKit
import Foundation

class RewindScoreInterfaceController: WKInterfaceController {

    @IBOutlet var matchScorePicker: WKInterfacePicker!
    
    var rewindScoreViewModel: RewindScoreViewModel?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
    
    @IBAction func matchScorePickerItemSelected(_ value: Int) {
        WKInterfaceDevice.current().play(.click)
        rewindScoreViewModel?.selectedMatchScoreIndex = value
    }

    @IBAction func saveButtonTapped() {
        rewindScoreViewModel?.rewindToSelectedMatchScoreIndex()
        dismiss()
    }
    
}
