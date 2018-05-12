import Foundation
import ObjectMapper

public class CFSpace: ImmutableMappable {
    public var guid: String
    public var name: String
    
    public required init(map: Map) throws
    {
        guid = try map.value("metadata.guid")
        name = try map.value("entity.name")
    }
    
    public func mapping(map: Map) {
        guid <- map["metadata.guid"]
        name <- map["entity.name"]
    }
}
