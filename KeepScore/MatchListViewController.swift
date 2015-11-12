import RealmSwift
import KeepScoreKit
import UIKit

class MatchListViewController: UITableViewController {
    
    var viewModel = MatchListViewModel()
    var liveMatch: Match?
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        notificationToken = realm.addNotificationBlock { [weak self] notification, realm in
            if let me = self {
                me.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let _ = liveMatch {
            self.performSegueWithIdentifier("ShowLiveMatch", sender: self)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let token = notificationToken {
            let realm = try! Realm()
            realm.removeNotification(token)
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let matches = viewModel.matches else {
            return 0
        }
        return matches.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let matchCell = tableView.dequeueReusableCellWithIdentifier("MatchCell", forIndexPath: indexPath)
        if let matches = viewModel.matches {
            let match = matches[indexPath.row] as Match
            matchCell.textLabel?.text = "\(match.homeTeamName) : \(match.awayTeamName)"
            matchCell.detailTextLabel?.text = "\(match.homeTeamScore) : \(match.awayTeamScore)"
        }
        return matchCell
    }
    
    // MARK: - Seques
    
    @IBAction func newMatchCancelled(unwindSegue: UIStoryboardSegue) { }
    
    @IBAction func newMatchCreated(unwindSegue: UIStoryboardSegue) {
        if let newMatchViewController = unwindSegue.sourceViewController as? NewMatchViewController {
            let newMatchViewModel = newMatchViewController.viewModel
            liveMatch = newMatchViewModel.startMatch()
        }
    }
    
    @IBAction func liveMatchCancelled(unwindSegue: UIStoryboardSegue) {
        liveMatch = nil
    }
    
    @IBAction func liveMatchSaved(unwindSegue: UIStoryboardSegue) {
        liveMatch = nil
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController, let viewController = navigationController.childViewControllers[0] as? LiveMatchViewController, let liveMatch = liveMatch {
            
            viewController.match = liveMatch
        }
    }
    
}
