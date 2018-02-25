import Foundation
import ObjectMapper

public class Instance: ImmutableMappable {
    var state: String
    
    var cpuUsage: Double?
    var memoryUsage: Int?
    var diskUsage: Int?
    
    var uris: [String]?
    var memoryQuota: Int?
    var diskQuota: Int?
    
    public required init(map: Map) throws {
        state = try map.value("state")
        
        cpuUsage = try map.value("stats.usage.cpu")
        memoryUsage = try map.value("stats.usage.mem")
        diskUsage = try map.value("stats.usage.disk")
        
        uris = try map.value("stats.uris")
        memoryQuota = try map.value("stats.mem_quota")
        diskQuota = try map.value("stats.disk_quota")
    }
    
    public func mapping(map: Map) {
        state <- map["state"]
        
        cpuUsage <- map["stats.usage.cpu"]
        memoryUsage <- map["stats.usage.mem"]
        diskUsage <- map["stats.usage.disk"]
        
        uris <- map["stats.uris"]
        memoryQuota <- map["stats.mem_quota"]
        diskQuota <- map["stats.disk_quota"]
    }
    
    public func translatedState() -> String {
        return (state == "CRASHED" || state == "DOWN") ? "errored" : "started"
    }
    
    public func memoryUsageMB() -> Double {
        let memory = (memoryUsage != nil) ? toMb(Int(round(Double(memoryUsage!)))) : 0
        return memory
    }
    
    public func memoryQuotaMB() -> Double {
        return (memoryQuota != nil) ? toMb(memoryQuota!) : 0
    }
    
    public func diskUsageMB() -> Double {
        return (diskUsage != nil) ? toMb(diskUsage!) : 0
    }
    
    public func diskQuotaMB() -> Double {
        return (diskQuota != nil) ? toMb(diskQuota!) : 0
    }
    
    public func memoryUsagePercentage() -> Double {
        return toPercent(usage: memoryUsage!, quota: memoryQuota!)
    }
    
    public func diskUsagePercentage() -> Double {
        return (diskUsage != nil && diskQuota != nil) ? toPercent(usage: diskUsage!, quota: diskQuota!) : 0
    }
    
    public func cpuUsagePercentage() -> Double {
        return (cpuUsage != nil) ? round(cpuUsage! * 100) : 0
    }
    
    fileprivate func toPercent(usage: Int, quota: Int) -> Double {
        let usageDouble = Double(exactly: usage)!
        let quotaDouble = Double(exactly: quota)!
        
        return (quota != 0) ? round((usageDouble / quotaDouble)*1000)/10: 0
    }
    
    fileprivate func toMb(_ value: Int) -> Double {
        let valueDouble = Double(exactly: value)!
        
        return valueDouble / pow(1024.0,2.0)
    }
}
