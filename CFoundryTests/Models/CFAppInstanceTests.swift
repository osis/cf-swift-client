import Foundation
import XCTest

@testable import CFoundry

class CFAppInstanceTests: CFModelTestBase {
    var runningInstance: CFAppInstance?
    var stoppedInstance: CFAppInstance?
    
    override func setUp() {
        super.setUp()
    
        let appStats = localResponseObject(t: CFAppStats.self, name: "app_stats", keyPath: "")
        runningInstance = appStats.instances[0]
        stoppedInstance = appStats.instances[1]
    }
    
    func testURIs() {
        XCTAssertEqual(runningInstance!.uris!, ["app_name.example.com", "other_name.example.com"])
    }
    
    func testState() {
        XCTAssertEqual(runningInstance!.state, "RUNNING")
        XCTAssertEqual(stoppedInstance!.state, "STOPPED")
    }
    
    func testReadableState() {
        XCTAssertEqual(runningInstance!.translatedState(), "started")
    }
    
    func testMemoryUsageMB() {
        XCTAssertEqual(runningInstance!.memoryUsageMB(), 28.49609375)
    }
    
    func testMemoryQuotaMB() {
        XCTAssertEqual(runningInstance!.memoryQuotaMB(), 512.0)
    }
    
    func testDiskUsageMB() {
        XCTAssertEqual(runningInstance!.diskUsageMB(), 63.31640625)
    }
    
    func testDiskQuotaMB() {
        XCTAssertEqual(runningInstance!.diskQuotaMB(), 1024.0)
    }
    
    func testMemoryUsagePercentage() {
        XCTAssertEqual(runningInstance!.memoryUsagePercentage(), 5.5999999999999996)
    }
    
    func testDiskUsagePercentage() {
        XCTAssertEqual(runningInstance!.diskUsagePercentage(), 6.2000000000000002)
    }
    
    func testCPUUsagePercentage() {
        XCTAssertEqual(runningInstance!.cpuUsagePercentage(), 14.0)
    }
}
