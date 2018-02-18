import Foundation
import XCTest

@testable import CFoundry

class CFSpaceTests: CFModelTestBase {
    var space: CFSpace?
    
    override func setUp() {
        super.setUp()
        space = localResponseArray(t: CFSpace.self, name: "spaces")[0]
    }
    
    func testGuid() {
        XCTAssertEqual(space!.guid, "d8f194c7-fe28-432e-84bb-8cc337aa7078")
    }
    
    func testName() {
        XCTAssertEqual(space!.name, "test-space-0")
    }
}
