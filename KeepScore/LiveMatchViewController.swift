import UIKit
import KeepScoreKit
import RealmSwift

class LiveMatchViewController: UITableViewController {

    var match: Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        let realm = try! Realm()
        
        do {
            realm.beginWrite()
            realm.add(match)
            try realm.commitWrite()
        } catch {
            print("Could not save match: \(match)")
        }
        performSegueWithIdentifier("LiveMatchSaved", sender: self)
    }
    
}
