import Foundation
import RealmSwift

public class Match: Object {
    
    dynamic public var id = NSUUID().UUIDString
    dynamic public var activityType = ActivityType.Other.rawValue
    dynamic public var homeTeamName = "Home"
    dynamic public var homeTeamScore = 0
    dynamic public var awayTeamName = "Away"
    dynamic public var awayTeamScore = 0
    dynamic public var startedAt = NSDate()
    dynamic public var endedAt: NSDate?
    
    var matchScoreList = List<MatchScore>()

    public var matchScores: [MatchScore] {
        get {
            var scores = [MatchScore]()
            for matchScore in matchScoreList {
                scores.append(matchScore)
            }
            return scores
        }
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public convenience init(activityType: ActivityType, homeTeamName: String, awayTeamName: String) {
        self.init()
        self.activityType = activityType.rawValue
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.matchScoreList.insert(MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate()), atIndex: 0)
        self.homeTeamScore = 0
        self.awayTeamScore = 0
    }
    
    public func incrementHomeTeamScore() {
        if let lastScore = matchScoreList.first {
            let newHomeTeamScore = lastScore.homeTeamScore + 1
            let newScore = MatchScore(homeTeamScore: newHomeTeamScore, awayTeamScore: lastScore.awayTeamScore, createdAt: NSDate())
            matchScoreList.insert(newScore, atIndex: 0)
            homeTeamScore = newScore.homeTeamScore
        }
    }
    
    public func incrementAwayTeamScore() {
        if let lastScore = matchScoreList.first {
            let newAwayTeamScore = lastScore.awayTeamScore + 1
            let newScore = MatchScore(homeTeamScore: lastScore.homeTeamScore, awayTeamScore: newAwayTeamScore, createdAt: NSDate())
            matchScoreList.insert(newScore, atIndex: 0)
            awayTeamScore = newScore.awayTeamScore
        }
    }
    
    public func revertLastScore() {
        if (matchScoreList.count != 1) {
            matchScoreList.removeFirst()
            if let newScore = matchScoreList.first {
                self.homeTeamScore = newScore.homeTeamScore
                self.awayTeamScore = newScore.awayTeamScore
            }
        }
    }
    
    public func reset() {
        let newScore = MatchScore(homeTeamScore: 0, awayTeamScore: 0, createdAt: NSDate())
        matchScoreList.insert(newScore, atIndex: 0)
        self.homeTeamScore = 0
        self.awayTeamScore = 0
    }
    
    public func dictionary() -> [String: AnyObject] {
        
        var dictionary = [String: AnyObject]()
        
        dictionary["id"] = self.id
        dictionary["type"] = self.activityType
        dictionary["homeTeamName"] = self.homeTeamName
        dictionary["homeTeamScore"] = self.homeTeamScore
        dictionary["awayTeamName"] = self.awayTeamName
        dictionary["awayTeamScore"] = self.awayTeamScore
        dictionary["startedAt"] = self.startedAt.timeIntervalSince1970
        if let endedAtDate = self.endedAt {
            dictionary["endedAt"] = endedAtDate.timeIntervalSince1970
        }
        dictionary["matchScoreList"] = self.matchScoreList.map({ (matchScore: MatchScore) -> [String: AnyObject] in
            return matchScore.dictionary()
        })
        
        return dictionary
    }
    
    public static func fromDictionary(dictionary: [String: AnyObject]) throws -> Match {
        
        guard let id = dictionary["id"] as? String, let type = dictionary["type"] as? String, let homeTeamName = dictionary["homeTeamName"] as? String, let homeTeamScore = dictionary["homeTeamScore"] as? Int, let awayTeamName = dictionary["awayTeamName"] as? String, let awayTeamScore = dictionary["awayTeamScore"] as? Int, let startedAt = dictionary["startedAt"] as? NSTimeInterval else {
            throw MatchError.IncompleteMatchInfo
        }
        let match = Match(activityType: ActivityType(rawValue: type)!, homeTeamName: homeTeamName, awayTeamName: awayTeamName)
        match.id = id
        match.homeTeamScore = homeTeamScore
        match.awayTeamScore = awayTeamScore
        match.startedAt = NSDate(timeIntervalSince1970: startedAt)
        if let endedAt = dictionary["endedAt"] as? NSTimeInterval {
            match.endedAt = NSDate(timeIntervalSince1970: endedAt)
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

public class MatchScore: Object {
    
    dynamic public var homeTeamScore: Int = 0
    dynamic public var awayTeamScore: Int = 0
    dynamic public var createdAt = NSDate()
    
    convenience init(homeTeamScore: Int, awayTeamScore: Int, createdAt: NSDate) {
        self.init()
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.createdAt = createdAt
    }
        
    func dictionary() -> [String: AnyObject] {
        
        var dictionary = [String: AnyObject]()
        
        dictionary["homeTeamScore"] = self.homeTeamScore
        dictionary["awayTeamScore"] = self.awayTeamScore
        dictionary["createdAt"] = self.createdAt.timeIntervalSince1970
        
        return dictionary
    }
    
    static func fromDictionary(dictionary: [String: AnyObject]) throws -> MatchScore {
        
        guard let homeTeamScore = dictionary["homeTeamScore"] as? Int, let awayTeamScore = dictionary["awayTeamScore"] as? Int, let createdAt = dictionary["createdAt"] as? NSTimeInterval else {
            throw MatchError.IncompleteMatchInfo
        }
        return MatchScore(homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, createdAt: NSDate(timeIntervalSince1970: createdAt))
    }
    
}

public enum MatchError: ErrorType {
    case IncompleteMatchInfo
}
