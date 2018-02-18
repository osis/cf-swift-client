import Foundation
import ObjectMapper

public class CFApp: ImmutableMappable {
    
    public var guid: String = ""
    public var name: String = ""
    public var buildpack: String?
    public var detectedBuildpack: String?
    public var packageState: String = ""
    public var state: String = ""
    public var spaceGuid: String = ""
    public var diskQuota: Int32 = 0
    public var memory: Int32 = 0
    public var command: String = ""
    
    public required init(map: Map) throws
    {
        guid = try map.value("metadata.guid")
        name = try map.value("entity.name")
    }
    
    public func mapping(map: Map) {
        guid <- map["metadata.guid"]
        name <- map["entity.name"]
        buildpack <- map["entity.buildpack"]
        detectedBuildpack <- map["entity.detected_buildpack"]
        packageState <- map["entity.package_state"]
        state <- map["state"]
        spaceGuid <- map["space_guid"]
        diskQuota <- map["disk_quota"]
        memory <- map["memory"]
        command <- map["command"]
    }
    
    public func activeBuildpack() -> String {
        if ((detectedBuildpack?.isEmpty) == false) {
            return detectedBuildpack!
        }
        
        if ((buildpack?.isEmpty) == false) {
            return buildpack!
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
