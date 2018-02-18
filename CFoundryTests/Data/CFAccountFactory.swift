import Foundation
import SwiftyJSON

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
        let json = JSON(data: data! as Data)
        return CFInfo(json: json)
    }
    
    class func account() -> CFAccount {
        return CFAccount(
            target: target,
            username: username,
            password: password,
            info: info()
        )
    }
}
