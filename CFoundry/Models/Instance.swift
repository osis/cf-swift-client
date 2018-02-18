import Foundation
import CoreData
import SwiftyJSON

public class Instance: NSObject {
    
    public var json: JSON?
    
    public init(json: JSON) {
        super.init()
        self.json = json
    }
    
    public func uri() -> String? {
        let uris = stats()!["uris"]
        return (uris != nil && uris!.arrayValue.count > 0) ? "https://" + uris!.arrayValue[0].stringValue : nil
    }
    
    public func state() -> String {
        let state = json!["state"].stringValue
        return (state == "CRASHED" || state == "DOWN") ? "errored" : "started"
    }
    
    public func cpuUsagePercentage() -> Double {
        return (usage() != nil) ? round(usage()!["cpu"]!.doubleValue * 100) : 0
    }
    
    public func memoryUsage() -> Double {
        let memory = (usage() != nil) ? toMb(round(usage()!["mem"]!.doubleValue * 100)) : 0
        return memory
    }
    
    public func memoryQuota() -> Double {
        let memoryQuota = (stats() != nil) ? toMb(stats()!["mem_quota"]!.doubleValue) : 0
        return memoryQuota
    }
    
    public func memoryUsagePercentage() -> Double {
        return toPercent(Double(memoryUsage()), quota: Double(memoryQuota()))
    }
    
    public func diskUsage() -> Double {
        let disk = (usage() != nil) ? toMb(round(usage()!["disk"]!.doubleValue * 100)) : 0
        return disk
    }
    
    public func diskQuota() -> Double {
        let diskQuota = (stats() != nil) ? toMb(stats()!["disk_quota"]!.doubleValue) : 0
        return diskQuota
    }
    
    public func diskUsagePercentage() -> Double {
        return toPercent(Double(diskUsage()), quota: Double(diskQuota()))
    }
    
    fileprivate func usage() -> [String: JSON]? {
        let usage = stats()?["usage"]
        return (usage != nil) ? usage!.dictionaryValue : nil
    }
    
    fileprivate func stats() -> [String: JSON]? {
        let stats = json!["stats"]
        return (stats != JSON.null) ? stats.dictionaryValue : nil
    }
    
    fileprivate func toPercent(_ usage: Double, quota: Double) -> Double {
        return (quota != 0) ? round(10*(usage / quota))/10: 0
    }
    
    fileprivate func toMb(_ i: Double) -> Double {
        return i / pow(1024.0,2.0)
    }
}
