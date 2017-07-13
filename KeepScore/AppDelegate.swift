import UIKit
import HealthKit
import WatchConnectivity
import RealmSwift
import KeepScoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        debugPrint(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            if (session.isPaired != true) {
                debugPrint("Apple Watch is not paired")
            }
            
            if (session.isWatchAppInstalled != true) {
                debugPrint("WatchKit app is not installed")
            }
            
        } else {
            debugPrint("WatchConnectivity is not supported on this device")
        }
        
        return true
    }

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        healthStore.handleAuthorizationForExtension { success, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        debugPrint("Save match: \(userInfo)")
        let realm = try! Realm()
        
        do {
            let match = try Match.fromDictionary(userInfo as [String : AnyObject])
            realm.beginWrite()
            realm.add(match)
            try realm.commitWrite()
        } catch {
            print("Could not save match: \(userInfo)")
        }

    }
    
}
