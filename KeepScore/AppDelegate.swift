import UIKit
import HealthKit
import WatchConnectivity
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        debugPrint(Realm.Configuration.defaultConfiguration.path)
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            if (session.paired != true) {
                debugPrint("Apple Watch is not paired")
            }
            
            if (session.watchAppInstalled != true) {
                debugPrint("WatchKit app is not installed")
            }
            
        } else {
            debugPrint("WatchConnectivity is not supported on this device")
        }
        
        return true
    }

    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        healthStore.handleAuthorizationForExtensionWithCompletion { success, error in
            if let error = error {
                debugPrint(error.debugDescription)
            }
        }
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let realm = try! Realm()
        
        var match: Match?
        var update = false
        if let matchId = message["id"] as? String {
            match = realm.objectForPrimaryKey(Match.self, key: matchId)
        } else {
            try! realm.write {
                match = realm.create(Match.self)
            }
        }
        
        if match == nil {
            match = Match()
        } else {
            update = true
        }
        if let match = match,
            let homeTeamScore = message["homeTeamScore"] as? Int,
            let homeTeamName = message["homeTeamName"] as? String,
            let awayTeamScore = message["awayTeamScore"] as? Int,
            let awayTeamName = message["awayTeamName"] as? String {
            try! realm.write {
                match.homeTeamScore = homeTeamScore
                match.homeTeamName = homeTeamName
                match.awayTeamScore = awayTeamScore
                match.awayTeamName = awayTeamName
                realm.add(match, update: update)
            }
            replyHandler(["id": match.id])
        } else {
            replyHandler(["id": ""])
        }
        let center = NSNotificationCenter.defaultCenter()
        center.postNotification(NSNotification(name: "notification", object: nil, userInfo: message))
    }
    
}
