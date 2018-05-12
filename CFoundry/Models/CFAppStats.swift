import Foundation
import ObjectMapper

public class CFAppStats: ImmutableMappable {
    public var instances:[CFAppInstance]

    public required init(map: Map) throws {
        instances = []
    }
    
    public func mapping(map: Map) {
        let keysArray = Array(map.JSON.keys)
        for key in keysArray {
            let json = map.JSON[key] as! [String : Any]
            let instance = try! Mapper<CFAppInstance>().map(JSON: json)
            
            instances.append(instance)
        }
    }
}
