import Foundation
import ObjectMapper

public class CFApp: ImmutableMappable {
    
    public var guid: String
    public var spaceGuid: String
    public var name: String
    public var packageState: String
    public var state: String
    public var diskQuota: Int32
    public var memory: Int32
    public var buildpack: String?
    public var detectedBuildpack: String?
    public var command: String?
    
    public var serviceBindings: [CFServiceBinding]?
    
    public required init(map: Map) throws
    {
        let (guidPath, propPath) = CFApp.propertyPath(map: map)
        
        guid = try map.value("\(guidPath)guid")
        name = try map.value("\(propPath)name")
        packageState = try map.value("\(propPath)package_state")
        state = try map.value("\(propPath)state")
        spaceGuid = try map.value("\(propPath)space_guid")
        diskQuota = try map.value("\(propPath)disk_quota")
        memory = try map.value("\(propPath)memory")
    }
    
    private static func propertyPath(map: Map) -> (String, String) {
        if map.JSON["entity"] != nil {
            return ("metadata.", "entity.")
        }
        return ("", "")
    }
    
    public func mapping(map: Map)
    {
        let (guidPath, propPath) = CFApp.propertyPath(map: map)
        
        guid <- map["\(guidPath)guid"]
        name <- map["\(propPath)name"]
        buildpack <- map["\(propPath)buildpack"]
        detectedBuildpack <- map["\(propPath)detected_buildpack"]
        packageState <- map["\(propPath)package_state"]
        state <- map["\(propPath)state"]
        spaceGuid <- map["\(propPath)space_guid"]
        diskQuota <- map["\(propPath)disk_quota"]
        memory <- map["\(propPath)memory"]
        command <- map["\(propPath)command"]
        
        serviceBindings <- map["\(propPath)services"]
    }
    
    public func activeBuildpack() -> String {
        if let pack = detectedBuildpack {
            return pack
        }
        
        if let pack = buildpack {
            return pack
        }
        
        return ""
    }
    
    public func statusImageName() -> String {
        switch state {
        case "STARTED":
            return (packageState == "FAILED") ? "errored" : "started"
        default:
            return "stopped"
        }
    }
    
    public func formattedMemory() -> String {
        return byteCount(memory)
    }
    
    public func formattedDiskQuota() -> String {
        return byteCount(diskQuota)
    }
    
    fileprivate func byteCount(_ i: Int32) -> String {
        let count = Int64.init(i) * 1048576
        return ByteCountFormatter.string(fromByteCount: count, countStyle: ByteCountFormatter.CountStyle.memory)
    }
}
