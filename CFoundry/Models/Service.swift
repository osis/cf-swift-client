import Foundation
import CoreData
import SwiftyJSON

public class Service: NSObject {
    
    public var json: JSON?
    
    public init(json: JSON) {
        super.init()
        self.json = json
    }
    
    public func name() -> String {
        return json!["service_plan"]["service"]["label"].stringValue
    }
    
    public func planName() -> String {
        return json!["service_plan"]["name"].stringValue
    }
}
