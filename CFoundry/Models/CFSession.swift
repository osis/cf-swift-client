import Foundation
import UIKit
import Alamofire

public class CFSession {
    static let loginAuthToken = "Y2Y6"
    
    public let info: CFInfo
    public let target: String
    
    public var accessToken: String?
    public var refreshToken: String?
    
    init(account: CFAccount) {
        self.info = account.info
        self.target = account.target
    }
}
