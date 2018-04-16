import Foundation
import UIKit
import Alamofire

public class CFSession {
    static let loginAuthToken = "Y2Y6"
    
    let info: CFInfo
    let target: String
    
    var accessToken: String?
    var refreshToken: String?
    
    init(account: CFAccount) {
        self.info = account.info
        self.target = account.target
    }
}
