import XCTest

@testable import CFoundry

class CFAppsTests: CFModelTestBase {
    var apps: [CFApp]?
    
    override func setUp() {
        super.setUp()
        
        apps = localResponseArray(t: CFApp.self, name: "apps")
    }
    
    func testGuid() {
        XCTAssertEqual(apps![0].guid, "12f830d7-2ec9-4c66-ad0a-dc5d32affb1f")
    }
    
    func testSpaceGuid() {
        XCTAssertEqual(apps![0].spaceGuid, "84ab199d-4f64-4214-8146-7848e5bb2963")
    }
    
    func testName() {
        XCTAssertEqual(apps![0].name, "name-1568")
    }
    
    func testPackageState() {
        XCTAssertEqual(apps![0].packageState, "PENDING")
    }
    
    func testState() {
        XCTAssertEqual(apps![0].state, "STOPPED")
    }
    
    func testDiskQuota() {
        XCTAssertEqual(apps![0].diskQuota, 512)
    }
    
    func testMemory() {
        XCTAssertEqual(apps![0].memory, 1024)
    }
    
    func testBuildPack() {
        XCTAssertNil(apps![0].buildpack)
        XCTAssertNil(apps![1].buildpack)
        XCTAssertEqual(apps![2].buildpack!, "https://github.com/cloudfoundry/go-buildpack")
    }
    
    func testDetectedBuildPack() {
        XCTAssertNil(apps![0].detectedBuildpack)
        XCTAssertEqual(apps![1].detectedBuildpack, "ruby")
        XCTAssertNil(apps![2].detectedBuildpack)
    }
    
    func testCommand() {
        XCTAssertNil(apps![0].command)
        XCTAssertEqual(apps![1].command, "rails s")
        XCTAssertNil(apps![2].command)
    }
    
    func testActiveBuildpackViaBuildpack() {
        XCTAssertEqual(apps![0].activeBuildpack(), "", "Active buildpack is empty when there is no buildpack information.")
        
        XCTAssertEqual(apps![1].activeBuildpack(), "ruby", "Active buildpack is detected buildpack when one isn't defined.")
        
        XCTAssertEqual(apps![2].activeBuildpack(), "https://github.com/cloudfoundry/go-buildpack", "Active buildpack is buildpack when defined and there is no detected buildpack")
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
    
    func testFormattedMemory() {
        XCTAssertEqual(apps![0].formattedMemory(), "1 GB")
    }
    
    func testFormattedDiskQuota() {
        XCTAssertEqual(apps![0].formattedDiskQuota(), "512 MB")
    }
    
    func testServicesPresence() {
        XCTAssertNil(apps![0].serviceBindings)
    }
}
