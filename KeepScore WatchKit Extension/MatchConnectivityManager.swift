import WatchKit
import WatchConnectivity
import KeepScoreKit

class MatchConnectivityManager: NSObject {

    func saveMatch(_ match: Match) {
        
        if WCSession.default().isReachable {
            let requestValues = match.dictionary()
            
            let session = WCSession.default()
            session.transferUserInfo(requestValues)
        }
        
    }

}
