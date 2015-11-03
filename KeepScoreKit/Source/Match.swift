import Foundation

public class Match {
    
    public var activityType = ActivityType.Other
    public var id: String?
    public var homeTeamName = "Home"
    public var homeTeamScore: Int {
        get {
            guard let score = matchScores.first else {
                return 0
            }
            return score.homeTeamScore
        }
    }
    
    public var awayTeamName = "Away"
    public var awayTeamScore: Int {
        get {
            guard let score = matchScores.first else {
                return 0
            }
            return score.awayTeamScore
        }
    }
    
    public var matchScores = [MatchScore]()
    
    public init(activityType: ActivityType, homeTeamName: String, awayTeamName: String) {
        self.activityType = activityType
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        matchScores.insert(MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate()), atIndex: 0)
    }
    
    public func incrementHomeTeamScore() {
        if let lastScore = matchScores.first {
            let newHomeTeamScore = lastScore.homeTeamScore + 1
            let newScore = MatchScore(homeTeamScore: newHomeTeamScore, awayTeamScore: lastScore.awayTeamScore, createdAt: NSDate())
            matchScores.insert(newScore, atIndex: 0)
        }
    }
    
    public func incrementAwayTeamScore() {
        if let lastScore = matchScores.first {
            let newAwayTeamScore = lastScore.awayTeamScore + 1
            let newScore = MatchScore(homeTeamScore: lastScore.homeTeamScore, awayTeamScore: newAwayTeamScore, createdAt: NSDate())
            matchScores.insert(newScore, atIndex: 0)
        }
    }
    
    public func revertLastScore() {
        if (matchScores.count != 1) {
            matchScores.removeFirst()
        }
    }
    
    public func reset() {
        let newScore = MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate())
        matchScores.insert(newScore, atIndex: 0)
    }
    
    public func description() -> String {
        return "\(homeTeamName) \(homeTeamScore) : \(awayTeamName) \(awayTeamScore)"
    }
    
}

public struct MatchScore {
    
    public let homeTeamScore: Int
    public let awayTeamScore: Int
    public let createdAt: NSDate
    
    init(homeTeamScore: Int, awayTeamScore: Int, createdAt: NSDate) {
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.createdAt = NSDate(timeIntervalSince1970: createdAt.timeIntervalSince1970)
    }
    
}