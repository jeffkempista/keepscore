import Foundation

public class Match {
    
    public var activityType = ActivityType.Other
    public var homeTeamName = "Home"
    public var homeTeamScore: Int {
        get {
            guard let score = _matchScores.last else {
                return 0
            }
            return score.homeTeamScore
        }
    }
    
    public var awayTeamName = "Away"
    public var awayTeamScore: Int {
        get {
            guard let score = _matchScores.last else {
                return 0
            }
            return score.awayTeamScore
        }
    }
    
    private var _matchScores = [MatchScore]()
    
    public var matchScores: [MatchScore] {
        get {
            return _matchScores.map { $0 }
        }
    }
    
    public init(activityType: ActivityType, homeTeamName: String, awayTeamName: String) {
        self.activityType = activityType
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        _matchScores.append(MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate()))
    }
    
    public func incrementHomeTeamScore() {
        if let lastScore = _matchScores.last {
            let newHomeTeamScore = lastScore.homeTeamScore + 1
            let newScore = MatchScore(homeTeamScore: newHomeTeamScore, awayTeamScore: lastScore.awayTeamScore, createdAt: NSDate())
            _matchScores.append(newScore)
        }
    }
    
    public func incrementAwayTeamScore() {
        if let lastScore = _matchScores.last {
            let newAwayTeamScore = lastScore.awayTeamScore + 1
            let newScore = MatchScore(homeTeamScore: lastScore.homeTeamScore, awayTeamScore: newAwayTeamScore, createdAt: NSDate())
            _matchScores.append(newScore)
        }
    }
    
    public func revertLastScore() {
        if (_matchScores.count != 1) {
            _matchScores.removeLast()
        }
    }
    
    public func reset() {
        _matchScores.append(MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate()))
    }
    
    public func description() -> String {
        return "\(homeTeamName) \(homeTeamScore) : \(awayTeamName) \(awayTeamScore)"
    }
    
}

public struct MatchScore {
    
    let homeTeamScore: Int
    let awayTeamScore: Int
    let createdAt: NSDate
    
    init(homeTeamScore: Int, awayTeamScore: Int, createdAt: NSDate) {
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.createdAt = NSDate(timeIntervalSince1970: createdAt.timeIntervalSince1970)
    }
    
}