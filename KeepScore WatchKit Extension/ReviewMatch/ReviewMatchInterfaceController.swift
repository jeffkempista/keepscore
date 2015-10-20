import WatchKit
import Foundation


class ReviewMatchInterfaceController: WKInterfaceController {

    @IBOutlet var homeTeamNameLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamNameLabel: WKInterfaceLabel!
    @IBOutlet var homeTeamScoreLabel: WKInterfaceLabel!
    @IBOutlet var awayTeamScoreLabel: WKInterfaceLabel!

    var reviewMatchViewModel: ReviewMatchViewModel?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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
        debugPrint("saveButtonTapped")
        self.reviewMatchViewModel?.saveMatch()
        dismissController()
    }
    
    @IBAction func discardButtonTapped() {
        debugPrint("discardButtonTapped")
        self.reviewMatchViewModel?.discardMatch()
        dismissController()
    }
    
}
