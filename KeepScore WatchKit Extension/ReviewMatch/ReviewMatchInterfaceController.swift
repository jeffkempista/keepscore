import WatchKit
import Foundation


class ReviewMatchInterfaceController: WKInterfaceController {

    @IBOutlet var homeTeamNameLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamNameLabel: WKInterfaceLabel!
    @IBOutlet var homeTeamScoreLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamScoreLabel: WKInterfaceLabel!

    var reviewMatchViewModel: ReviewMatchViewModel?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let reviewMatchViewModel = context as? ReviewMatchViewModel {
            self.reviewMatchViewModel = reviewMatchViewModel
            
            let match = reviewMatchViewModel.match
            homeTeamNameLabel.setText(match.homeTeamName)
            awayTeamNameLabel.setText(match.awayTeamName)
            homeTeamScoreLabel.setText("\(match.homeTeamScore)")
            awayTeamScoreLabel.setText("\(match.awayTeamScore)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.reviewMatchViewModel = nil
    }

    @IBAction func saveButtonTapped() {
        self.reviewMatchViewModel?.saveMatch()
        
        let alert = WKAlertAction(title: "OK", style: .default) {
            self.dismiss()
        }
        presentAlert(withTitle: "Match Saved", message: "Huzzah!", preferredStyle: .alert, actions: [alert])
    }
    
    @IBAction func discardButtonTapped() {
        self.reviewMatchViewModel?.discardMatch()
        dismiss()
    }
    
}
