import WatchKit
import WatchConnectivity
import KeepScoreKit

class MatchConnectivityManager: NSObject {

    func saveMatch(match: Match) {
        
        if WCSession.defaultSession().reachable {
            match.startedOnWatch = true
            let requestValues = match.dictionary()
            
            let session = WCSession.defaultSession()
            session.transferUserInfo(requestValues)
        }
        
    }

}
