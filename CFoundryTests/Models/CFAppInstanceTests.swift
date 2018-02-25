import Foundation
import XCTest

@testable import CFoundry

class CFAppInstanceTests: CFModelTestBase {
    var instance: CFAppInstance?
    
    override func setUp() {
        super.setUp()
        
        instance = localResponseObject(t: CFAppInstance.self, name: "app_stats", keyPath: "0")
    }
    
    func testURIs() {
        XCTAssertEqual(instance!.uris!, ["app_name.example.com", "other_name.example.com"])
    }
    
    func testState() {
        XCTAssertEqual(instance!.state, "RUNNING")
    }
    
    func testReadableState() {
        XCTAssertEqual(instance!.translatedState(), "started")
    }
    
    func testMemoryUsageMB() {
        XCTAssertEqual(instance!.memoryUsageMB(), 28.49609375)
    }
    
    func testMemoryQuotaMB() {
        XCTAssertEqual(instance!.memoryQuotaMB(), 512.0)
    }
    
    func testDiskUsageMB() {
        XCTAssertEqual(instance!.diskUsageMB(), 63.31640625)
    }
    
    func testDiskQuotaMB() {
        XCTAssertEqual(instance!.diskQuotaMB(), 1024.0)
    }
    
    func testMemoryUsagePercentage() {
        XCTAssertEqual(instance!.memoryUsagePercentage(), 5.5999999999999996)
    }
    
    func testDiskUsagePercentage() {
        XCTAssertEqual(instance!.diskUsagePercentage(), 6.2000000000000002)
    }
    
    func testCPUUsagePercentage() {
        XCTAssertEqual(instance!.cpuUsagePercentage(), 14.0)
    }
}
