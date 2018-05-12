import Foundation
import ObjectMapper

@testable import CFoundry

class CFAccountFactory {
    static let username = "cfUser"
    static let password = "cfPass"
    static let target = "https://api.test.io"
    static let oauthToken = "testToken"
    
    class func info() -> CFInfo {
        let bundle = Bundle.init(for: CFAccountFactory.self)
        let path = bundle.path(forResource: "info", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
        
        let info = try! Mapper<CFInfo>().map(JSON: json!)
        
        return info
    }
    
    class func account() -> CFAccount {
        return CFAccount(
            target: target,
            username: username,
            password: password,
            info: info()
        )
    }
    
    class func session() -> CFSession {
        return CFSession(account: self.account())
    }
}
