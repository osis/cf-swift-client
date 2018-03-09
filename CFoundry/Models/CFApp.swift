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
    
    public required init(map: Map) throws
    {
        guid = try map.value("metadata.guid")
        name = try map.value("entity.name")
        packageState = try map.value("entity.package_state")
        state = try map.value("entity.state")
        spaceGuid = try map.value("entity.space_guid")
        diskQuota = try map.value("entity.disk_quota")
        memory = try map.value("entity.memory")
    }
    
    public func mapping(map: Map) {
        guid <- map["metadata.guid"]
        name <- map["entity.name"]
        buildpack <- map["entity.buildpack"]
        detectedBuildpack <- map["entity.detected_buildpack"]
        packageState <- map["entity.package_state"]
        state <- map["entity.state"]
        spaceGuid <- map["entity.space_guid"]
        diskQuota <- map["entity.disk_quota"]
        memory <- map["entity.memory"]
        command <- map["entity.command"]
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
