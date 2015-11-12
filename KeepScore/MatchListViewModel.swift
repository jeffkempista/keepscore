import Foundation
import KeepScoreKit
import RealmSwift

class MatchListViewModel: NSObject {

    var matches: Results<Match>?
    
    override init() {
        let realm = try! Realm()
        matches = realm.objects(Match.self).sorted("startedAt", ascending: false)
    }
    
}
