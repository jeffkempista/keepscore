import RealmSwift
import Foundation

class Match: Object {
    
    dynamic var id: String = NSUUID().UUIDString

    dynamic var homeTeamName = ""
    dynamic var awayTeamName = ""
    dynamic var homeTeamScore = 0
    dynamic var awayTeamScore = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
