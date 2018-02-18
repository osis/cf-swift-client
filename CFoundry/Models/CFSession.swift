import Foundation
import UIKit
import Alamofire

public class CFSession {
    static let loginAuthToken = "Y2Y6"
    static let accountKey = "currentAccount"
    static let orgKey = "currentOrg"
    
    static var oauthToken: String?
    static var baseURLString: String {
        if let account = CFSession.account() {
            return account.target
        }
        return ""
    }
    static var dopplerURLString: String {
        if let account = CFSession.account() {
            return account.info.dopplerLoggingEndpoint
        }
        return ""
    }
    
    public class func account(_ account: CFAccount) {
        UserDefaults.standard.set(account.account, forKey: accountKey)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AccountSwitched"), object: nil)
    }
    
    public class func account() -> CFAccount? {
        if let key = currentAccountKey() {
            return CFAccountStore.read(key)
        }
        return nil
    }
    
    public class func isCurrent(_ account: CFAccount) -> Bool {
        if let sessionAccount = self.account() {
            return sessionAccount.account == account.account
        }
        return false
    }
    
    public class func org(_ orgGuid: String) {
        return UserDefaults.standard.set(orgGuid, forKey: orgKey)
    }
    
    public class func org() -> String? {
        return UserDefaults.standard.object(forKey: orgKey) as! String?
    }
    
    public class func reset() {
        CFSession.oauthToken = nil
        cancelRequests()
        
        
        UserDefaults.standard.removeObject(forKey: accountKey)
        UserDefaults.standard.removeObject(forKey: orgKey)
    }
    
    public class func logout(_ isError: Bool) {
        if let account = CFSession.account() {
            try! CFAccountStore.delete(account)
        }
        
        reset()
        
        // TODO: Insert Callback
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        if CFAccountStore.isEmpty() {
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginController = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
//            loginController.authError = isError
//            delegate.window?.rootViewController = loginController
//        } else {
//            let appsController = delegate.showAppsScreen()
//            appsController.performSegue(withIdentifier: "accounts", sender: nil)
//        }
    }
    
    fileprivate class func cancelRequests() {
        Alamofire.SessionManager.default.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    fileprivate class func currentAccountKey() -> String? {
        return UserDefaults.standard.object(forKey: accountKey) as! String?
    }
}
