import Foundation
import Locksmith

public struct CFAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable,GenericPasswordSecureStorable {
    
    public let target: String
    public let username: String
    public let password: String
    
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
        let data: [String : AnyObject] = [
            "target" : target as AnyObject,
            "username" : username as AnyObject,
            "password" : password as AnyObject,
            "info" : info.serialize() as AnyObject
        ]

        return data
    }
}
