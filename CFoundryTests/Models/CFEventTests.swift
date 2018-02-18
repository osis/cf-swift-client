import Foundation
import XCTest

@testable import CFoundry

class CFEventTests: CFModelTestBase {
    var events: [CFEvent]?
    
    override func setUp() {
        super.setUp()
        events = localResponseArray(t: CFEvent.self, name: "events")
    }
    
    func operationEvent() -> CFEvent {
        return events![0]
    }
    
    func attributeEvent() -> CFEvent {
        return events![11]
    }
    
    func crashEvent() -> CFEvent {
        return events![8]
    }
    
    func testGuid() {
        XCTAssertEqual(operationEvent().guid, "6c5e9082-7dd7-4177-9e78-8b67c86cb796")
    }

    func testType() {
        XCTAssertEqual(operationEvent().readableType(), "operation")
        XCTAssertEqual(attributeEvent().readableType(), "update")
        XCTAssertEqual(crashEvent().readableType(), "crash")
    }
    
    func testTimestamp() {
        XCTAssertEqual(operationEvent().timestamp, "2016-05-24T16:22:07Z")
    }
    
    func testRawType() {
        XCTAssertEqual(operationEvent().type, "audit.app.update")
    }
    
    func testState() {
        XCTAssertEqual(operationEvent().requestedState, "STARTED")
        XCTAssertNil(attributeEvent().requestedState)
    }
    
    func testName() {
        XCTAssertNil(operationEvent().requestedName)
        XCTAssertEqual(attributeEvent().requestedName, "stemcells")
    }
    
    func testMemory() {
        XCTAssertNil(operationEvent().readableMemory())
        XCTAssertEqual(attributeEvent().readableMemory(), "64 MB")
    }
    
    func testDisk() {
        XCTAssertNil(operationEvent().readableDiskQuota())
        XCTAssertEqual(attributeEvent().readableDiskQuota(), "100 MB")
    }
    
    func testBuildpack() {
        XCTAssertNil(operationEvent().requestedBuildpack)
        XCTAssertEqual(attributeEvent().requestedBuildpack, "https://github.com/cloudfoundry-community/staticfile-buildpack.git")
    }
    
    func testEnvironmentJson() {
        XCTAssertNil(operationEvent().requestedEnvironmentJSON)
        XCTAssertEqual(attributeEvent().requestedEnvironmentJSON, "PRIVATE DATA HIDDEN")
    }
    
    func testIndex() {
        XCTAssertNil(operationEvent().index)
        XCTAssertEqual(crashEvent().index, 0)
    }
    
    func testExistDescription() {
        XCTAssertNil(operationEvent().exitDescription)
        XCTAssertEqual(crashEvent().exitDescription, "2 error(s) occurred:\n\n")
    }
    
    func testReason() {
        XCTAssertNil(operationEvent().reason)
        XCTAssertEqual(crashEvent().reason, "CRASHED")
    }

    func testAttributeSummary() {
        XCTAssertEqual(operationEvent().attributeSummary(), "")
        XCTAssertEqual(attributeEvent().attributeSummary(), "Name: stemcells, Instances: 1, Memory: 64 MB, Disk: 100 MB, Buildpack: https://github.com/cloudfoundry-community/staticfile-buildpack.git, Envionment JSON: PRIVATE DATA HIDDEN")
    }
}
