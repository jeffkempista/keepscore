import RealmSwift
import KeepScoreKit
import UIKit

class MatchListViewController: UITableViewController {
    
    var matches: Results<Match>?
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateMatches()
    }
    
    func populateMatches() {
        let realm = try! Realm()
        matches = realm.objects(Match.self).sorted(byKeyPath: "startedAt", ascending: false)
        notificationToken = realm.addNotificationBlock { [weak self] notification, realm in
            if let me = self {
                me.tableView.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let token = notificationToken {
            token.stop()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let matches = matches else {
            return 0
        }
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchCell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        if let matches = matches {
            let match = matches[indexPath.row] as Match
            matchCell.textLabel?.text = "\(match.homeTeamName) : \(match.awayTeamName)"
            matchCell.detailTextLabel?.text = "\(match.homeTeamScore) : \(match.awayTeamScore)"
        }
        return matchCell
    }
    
}

