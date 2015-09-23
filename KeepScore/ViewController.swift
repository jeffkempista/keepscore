import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName("notification", object: nil, queue: nil) { notification in
            let homeTeamScore = notification.userInfo?["homeTeamScore"] as! Int
            let awayTeamScore = notification.userInfo?["awayTeamScore"] as! Int
            self.homeScoreLabel.text = "\(homeTeamScore)"
            self.awayScoreLabel.text = "\(awayTeamScore)"
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

