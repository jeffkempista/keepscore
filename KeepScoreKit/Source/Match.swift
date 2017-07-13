import Foundation
import RealmSwift

open class Match: Object {
    
    dynamic open var id = UUID().uuidString
    dynamic open var activityType = ActivityType.Other.rawValue
    dynamic open var homeTeamName = "Home"
    dynamic open var homeTeamScore = 0
    dynamic open var awayTeamName = "Away"
    dynamic open var awayTeamScore = 0
    dynamic open var startedAt = Date()
    dynamic open var endedAt: Date?
    
    var matchScoreList = List<MatchScore>()

    open var matchScores: [MatchScore] {
        get {
            var scores = [MatchScore]()
            for matchScore in matchScoreList {
                scores.append(matchScore)
            }
            return scores
        }
    }
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
    public convenience init(activityType: ActivityType, homeTeamName: String, awayTeamName: String) {
        self.init()
        self.activityType = activityType.rawValue
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.matchScoreList.insert(MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: Date()), at: 0)
        self.homeTeamScore = 0
        self.awayTeamScore = 0
    }
    
    open func incrementHomeTeamScore() {
        if let lastScore = matchScoreList.first {
            let newHomeTeamScore = lastScore.homeTeamScore + 1
            let newScore = MatchScore(homeTeamScore: newHomeTeamScore, awayTeamScore: lastScore.awayTeamScore, createdAt: Date())
            matchScoreList.insert(newScore, at: 0)
            homeTeamScore = newScore.homeTeamScore
        }
    }
    
    open func incrementAwayTeamScore() {
        if let lastScore = matchScoreList.first {
            let newAwayTeamScore = lastScore.awayTeamScore + 1
            let newScore = MatchScore(homeTeamScore: lastScore.homeTeamScore, awayTeamScore: newAwayTeamScore, createdAt: Date())
            matchScoreList.insert(newScore, at: 0)
            awayTeamScore = newScore.awayTeamScore
        }
    }
    
    open func revertLastScore() {
        if (matchScoreList.count != 1) {
            matchScoreList.removeFirst()
            if let newScore = matchScoreList.first {
                self.homeTeamScore = newScore.homeTeamScore
                self.awayTeamScore = newScore.awayTeamScore
            }
        }
    }
    
    open func reset() {
        let newScore = MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: Date())
        matchScoreList.insert(newScore, at: 0)
        self.homeTeamScore = 0
        self.awayTeamScore = 0
    }
    
    open func dictionary() -> [String: AnyObject] {
        
        var dictionary = [String: AnyObject]()
        
        dictionary["id"] = self.id as AnyObject
        dictionary["type"] = self.activityType as AnyObject
        dictionary["homeTeamName"] = self.homeTeamName as AnyObject
        dictionary["homeTeamScore"] = self.homeTeamScore as AnyObject
        dictionary["awayTeamName"] = self.awayTeamName as AnyObject
        dictionary["awayTeamScore"] = self.awayTeamScore as AnyObject
        dictionary["startedAt"] = self.startedAt.timeIntervalSince1970 as AnyObject
        if let endedAtDate = self.endedAt {
            dictionary["endedAt"] = endedAtDate.timeIntervalSince1970 as AnyObject
        }
        dictionary["matchScoreList"] = self.matchScoreList.map { (matchScore) -> [String: AnyObject] in
            return matchScore.dictionary()
        } as AnyObject
        
        return dictionary
    }
    
    open static func fromDictionary(_ dictionary: [String: AnyObject]) throws -> Match {
        
        guard let id = dictionary["id"] as? String, let type = dictionary["type"] as? String, let homeTeamName = dictionary["homeTeamName"] as? String, let homeTeamScore = dictionary["homeTeamScore"] as? Int, let awayTeamName = dictionary["awayTeamName"] as? String, let awayTeamScore = dictionary["awayTeamScore"] as? Int, let startedAt = dictionary["startedAt"] as? TimeInterval else {
            throw MatchError.incompleteMatchInfo
        }
        let match = Match(activityType: ActivityType(rawValue: type)!, homeTeamName: homeTeamName, awayTeamName: awayTeamName)
        match.id = id
        match.homeTeamScore = homeTeamScore
        match.awayTeamScore = awayTeamScore
        match.startedAt = Date(timeIntervalSince1970: startedAt)
        if let endedAt = dictionary["endedAt"] as? TimeInterval {
            match.endedAt = Date(timeIntervalSince1970: endedAt)
        }
        if let matchScoreList = dictionary["matchScoreList"] as? [[String: AnyObject]] {
            
            for matchScoreDictionary in matchScoreList {
                let matchScore = try MatchScore.fromDictionary(matchScoreDictionary)
                match.matchScoreList.append(matchScore)
            }
        }
        return match
    }
    
}

open class MatchScore: Object {
    
    dynamic open var homeTeamScore: Int = 0
    dynamic open var awayTeamScore: Int = 0
    dynamic open var createdAt = Date()
    
    convenience init(homeTeamScore: Int, awayTeamScore: Int, createdAt: Date) {
        self.init()
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.createdAt = createdAt
    }
        
    func dictionary() -> [String: AnyObject] {
        
        var dictionary = [String: AnyObject]()
        
        dictionary["homeTeamScore"] = self.homeTeamScore as AnyObject
        dictionary["awayTeamScore"] = self.awayTeamScore as AnyObject
        dictionary["createdAt"] = self.createdAt.timeIntervalSince1970 as AnyObject
        
        return dictionary
    }
    
    static func fromDictionary(_ dictionary: [String: AnyObject]) throws -> MatchScore {
        
        guard let homeTeamScore = dictionary["homeTeamScore"] as? Int, let awayTeamScore = dictionary["awayTeamScore"] as? Int, let createdAt = dictionary["createdAt"] as? TimeInterval else {
            throw MatchError.incompleteMatchInfo
        }
        return MatchScore(homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, createdAt: Date(timeIntervalSince1970: createdAt))
    }
    
}

public enum MatchError: Error {
    case incompleteMatchInfo
}
