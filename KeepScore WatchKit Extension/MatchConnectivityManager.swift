import WatchKit
import WatchConnectivity
import KeepScoreKit

class MatchConnectivityManager: NSObject {

    func sendScoreUpdateInfo(match: Match) {
        if WCSession.defaultSession().reachable {
            var requestValues = [String: AnyObject]()
            if let id = match.id {
                requestValues["id"] = id
            }
            requestValues["type"] = "ScoreUpdate"
            requestValues["homeTeamName"] = match.homeTeamName
            requestValues["homeTeamScore"] = match.homeTeamScore
            requestValues["awayTeamName"] = match.awayTeamName
            requestValues["awayTeamScore"] = match.awayTeamScore
            
            let session = WCSession.defaultSession()
            
            session.sendMessage(requestValues, replyHandler: { (responseValues) -> Void in
                if let id = responseValues["id"] as? String {
                    match.id = id
                }
                if let homeTeamName = responseValues["homeTeamName"] as? String {
                    match.homeTeamName = homeTeamName
                }
                if let awayTeamName = responseValues["awayTeamName"] as? String {
                    match.awayTeamName = awayTeamName
                }
                }, errorHandler: nil)
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: nil)
        }
    }

}
