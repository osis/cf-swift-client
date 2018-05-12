import Foundation
import ObjectMapper

public class CFEvent: ImmutableMappable {
    public var guid: String
    public var type: String
    public var timestamp: String
    
    public var index: Int?
    public var exitDescription: String?
    public var reason: String?
    
    public var requestedName: String?
    public var requestedState: String?
    public var requestedMemory: Int?
    public var requestedInstances: Int?
    public var requestedDiskQuota: Int?
    public var requestedBuildpack: String?
    public var requestedEnvironmentJSON: String?
    
    public required init(map: Map) throws {
        guid = try map.value("metadata.guid")
        type = try map.value("entity.type")
        timestamp = try map.value("entity.timestamp")
        
        index = try? map.value("entity.metadata.index")
        exitDescription = try? map.value("entity.metadata.exit_description")
        reason = try? map.value("entity.metadata.reason")
        
        requestedName = try? map.value("entity.metadata.request.name")
        requestedState = try? map.value("entity.metadata.request.state")
        requestedMemory = try? map.value("entity.metadata.request.memory")
        requestedBuildpack = try? map.value("entity.metadata.request.buildpack")
        requestedInstances = try? map.value("entity.metadata.request.instances")
        requestedDiskQuota = try? map.value("entity.metadata.request.disk_quota")
        requestedEnvironmentJSON = try? map.value("entity.metadata.request.environment_json")
    }
    
    public func mapping(map: Map) throws {
        guid <- map["metadata.guid"]
        type <- map["entity.type"]
        timestamp <- map["entity.timestamp"]
        
        index <- map["entity.metadata.index"]
        exitDescription <- map["entity.metadata.exit_description"]
        reason <- map["entity.metadata.reason"]
        
        requestedName <- map["entity.metadata.request.name"]
        requestedState <- map["entity.metadata.request.state"]
        requestedMemory <- map["entity.metadata.request.memory"]
        requestedBuildpack <- map["entity.metadata.request.buildpack"]
        requestedInstances <- map["entity.metadata.request.instances"]
        requestedDiskQuota <- map["entity.metadata.request.disk_quota"]
        requestedEnvironmentJSON <- map["entity.metadata.request.environment_json"]
        
    }
    
    public func readableType() -> String? {
        switch type {
        case "audit.app.update":
            return isOperationalEvent() ? "operation" : "update"
        case "app.crash":
            return "crash"
        default:
            return nil
        }
    }
    
    public func readableMemory() -> String? {
        if let memory = requestedMemory {
            return formattedMemory(memory)
        }
        return nil
    }
    
    public func readableDiskQuota() -> String? {
        if let diskQuota = requestedDiskQuota {
            return formattedMemory(diskQuota)
        }
        return nil
    }
    
    public func isOperationalEvent() -> Bool {
        return type == "audit.app.update" && requestedState != nil
    }
    
    public func attributeSummary() -> String {
        var attributes = [String]()
        
        if let name = requestedName {
            attributes.append("Name: \(name)")
        }
        
        if let instances = requestedInstances {
            attributes.append("Instances: \(instances)")
        }
        
        if let memory = readableMemory() {
            attributes.append("Memory: \(memory)")
        }
        
        if let diskQuota = readableDiskQuota() {
            attributes.append("Disk: \(diskQuota)")
        }
        
        if let buildpack = requestedBuildpack {
            attributes.append("Buildpack: \(buildpack)")
        }
        
        if let envJson = requestedEnvironmentJSON {
            attributes.append("Envionment JSON: \(envJson)")
        }
        
        return attributes.joined(separator: ", ")
    }
    
    fileprivate func formattedMemory(_ value: Int) -> String {
        return byteCount(value)
    }
    
    fileprivate func formattedDiskQuota(_ value: Int) -> String {
        return byteCount(value)
    }
    
    fileprivate func byteCount(_ i: Int) -> String {
        let count = Int64(i) * 1048576
        return ByteCountFormatter.string(fromByteCount: count, countStyle: ByteCountFormatter.CountStyle.memory)
    }
}
