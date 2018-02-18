import UIKit
import XCTest
import CoreData

@testable import CFoundry

class CFAppsTests: CFModelTestBase {
    var apps: [CFApp]?
    
    override func setUp() {
        super.setUp()
        apps = localResponseArray(t: CFApp.self, name: "apps")
    }
    
    func testBuildPack() {
        XCTAssertEqual(apps![0].buildpack!, "moo", "Something")
    }
    
    func testGuid() {
        XCTAssert((apps![0].guid as Any) is String, "GUID is a String")
        XCTAssertEqual(apps![0].guid, "12f830d7-2ec9-4c66-ad0a-dc5d32affb1f")
    }
    
    func testNameType() {
        XCTAssertEqual(apps![0].name, "name-1568")
    }
    
    func testPackageStateType() {
        XCTAssertEqual(apps![0].packageState, "PENDING")
    }
    
    func testStateType() {
        XCTAssertEqual(apps![0].state, "STOPPED")
    }
    
    func testDiskQuotaType() {
        XCTAssertEqual(apps![0].diskQuota, 1024)
    }
    
    func testMemoryType() {
        XCTAssertEqual(apps![0].memory, 1024)
    }
    
    func testEmptyActiveBuildpack() {
        XCTAssertEqual(apps![0].activeBuildpack(), "", "Active buildpack is empty when there is no buildpack information")
    }
    
    func testActiveBuildpackViaBuildpack() {
        let app = apps![0]
        app.buildpack = "someBuildpack"
        
        XCTAssertEqual(app.activeBuildpack(), "someBuildpack", "Active buildpack is buildpack when provided and there is no detected buildpack")
    }
    
    func testActiveBuildpackViaDetectedBuildpack() {
        let app = apps![0]
        app.buildpack = "someBuildpack"
        app.detectedBuildpack = "someDetectedBuildpack"
        
        XCTAssertEqual(app.activeBuildpack(), "someDetectedBuildpack", "Active buildpack is detected buildpack when provided")
    }
    
    func testStatusImageNameError() {
        let app = apps![0]
        app.state = "STARTED"
        app.packageState = "FAILED"
        
        XCTAssertEqual(app.statusImageName(), "errored", "Status name should be error if app state started and the package state is failed.")
    }
    
    func testStatusImageNameStarted() {
        let app = apps![0]
        app.state = "STARTED"
        app.packageState = "NOFAIL"
        
        XCTAssertEqual(app.statusImageName(), "started", "Status name should be error if app state started and the package state is not failed")
    }
    
    func testStatusImageNameStopped() {
        let app = apps![0]
        app.state = "NOSTART"
        
        XCTAssertEqual(app.statusImageName(), "stopped", "Status name should be stopped if state is not started")
    }
}
