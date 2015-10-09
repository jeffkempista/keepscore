import UIKit
import HealthKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

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
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        debugPrint("didReceiveMessage: \(message)")
        let center = NSNotificationCenter.defaultCenter()
        center.postNotification(NSNotification(name: "notification", object: nil, userInfo: message))
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        debugPrint("didReceiveMessage: \(message)")
        let center = NSNotificationCenter.defaultCenter()
        center.postNotification(NSNotification(name: "notification", object: nil, userInfo: message))
    }
    
}

