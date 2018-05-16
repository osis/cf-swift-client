import Foundation
import SwiftyJSON
import ObjectMapper
import Locksmith

//public struct CFAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
public struct CFAccount {

    public let target: String
    public let username: String
    public let password: String
    
    public var accessToken: String?
    public var refreshToken: String?

    public let info: CFInfo
    
    public init(target: String, username: String, password: String, info: CFInfo) {
        self.target = target
        self.username = username
        self.password = password
        self.info = info
    }
    
    public let service = "CloudFoundry"
    public var account: String { return "\(username)_\(target)" }
    
    public var data: [String : Any] {
        return self.serialize()
    }
    
    public func serialize() -> [String : Any] {
        let data: [String : AnyObject] = [
            "target" : target as AnyObject,
            "username" : username as AnyObject,
            "password" : password as AnyObject,
            "info" : info.serialize() as AnyObject
        ]

        return data
    }
    
    public static func deserialize(_ json: [String : Any]) -> CFAccount? {
        let infoJSON = json["info"] as! [String : Any]
        if let info = try? Mapper<CFInfo>().map(JSON: infoJSON) {
            return CFAccount(
                target: json["target"] as! String,
                username: json["username"] as! String,
                password: json["password"] as! String,
                info: info
            )
        }
        return nil
    }
}
