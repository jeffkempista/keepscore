import WatchKit
import KeepScoreKit

protocol RewindScoreDelegate: class {
    
    func matchScoreWasRewound(rewindScoreViewModel: RewindScoreViewModel)
    
}

class RewindScoreViewModel: NSObject {

    let matchConnectivityManager = MatchConnectivityManager()
    var match: Match
    var selectedMatchScoreIndex: Int
    weak var delegate: RewindScoreDelegate?
    
    var matchScores: [MatchScore] {
        get {
            return match.matchScores
        }
    }
    
    var matchScorePickerEnabled: Bool {
        get {
            return match.matchScores.count > 1
        }
    }
    
    init(match: Match) {
        self.match = match
        self.selectedMatchScoreIndex = 0
    }
    
    func rewindToSelectedMatchScoreIndex() {
        let start = 0
        let end = selectedMatchScoreIndex
        self.match.matchScores.removeRange(Range(start: start, end: end))
        matchConnectivityManager.sendScoreUpdateInfo(match)
        self.delegate?.matchScoreWasRewound(self)
    }
    
}
