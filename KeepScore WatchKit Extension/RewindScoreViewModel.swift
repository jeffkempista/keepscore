import WatchKit

protocol RewindScoreDelegate: class {
    
    func matchScoreWasRewound(rewindScoreViewModel: RewindScoreViewModel)
    
}

class RewindScoreViewModel: NSObject {

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
        self.selectedMatchScoreIndex = match.matchScores.count-1
    }
    
    func rewindToSelectedMatchScoreIndex() {
        let start = selectedMatchScoreIndex + 1
        let end = matchScores.count
        self.match.matchScores.removeRange(Range(start: start, end: end))
        self.delegate?.matchScoreWasRewound(self)
    }
    
}