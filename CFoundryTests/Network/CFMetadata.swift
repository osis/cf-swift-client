import Foundation
import ObjectMapper

public class CFMetadata: Mappable {
    
    var guid: String?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        guid <- map["guid"]
    }
}
