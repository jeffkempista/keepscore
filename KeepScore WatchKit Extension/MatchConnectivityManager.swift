import WatchKit
import WatchConnectivity
import KeepScoreKit

class MatchConnectivityManager: NSObject {

    func sendScoreUpdateInfo(match: Match) {
        if WCSession.defaultSession().reachable {
            let requestValues = ["type": "ScoreUpdate", "homeTeamScore" : match.homeTeamScore, "awayTeamScore": match.awayTeamScore] as [String: AnyObject]
            let session = WCSession.defaultSession()
            
            session.sendMessage(requestValues, replyHandler: nil, errorHandler: nil)
        }
    }

}
