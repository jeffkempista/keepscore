import UIKit
import HealthKit
import WatchConnectivity
import RealmSwift
import KeepScoreKit

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
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        debugPrint("Save match: \(userInfo)")
        let realm = try! Realm()
        
        do {
            let match = try Match.fromDictionary(userInfo)
            realm.beginWrite()
            realm.add(match)
            try realm.commitWrite()
        } catch {
            print("Could not save match: \(userInfo)")
        }

    }
    
}
