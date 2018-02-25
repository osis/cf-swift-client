import Foundation
import XCTest

@testable import CFoundry

class CFOrgTests: CFModelTestBase {
    var org: CFOrg?
    
    override func setUp() {
        super.setUp()
        
        org = localResponseArray(t: CFOrg.self, name: "orgs")[0]
    }
    
    func testGuid() {
        XCTAssert((org!.guid as Any) is String, "GUID is a String")
        XCTAssertEqual(org!.guid, "3832643e-b7d4-43ca-820c-be7774e381b2")
    }
    
    func testName() {
        XCTAssert((org!.name as Any) is String, "Name is a String")
        XCTAssertEqual(org!.name, "test-org-0")
    }
}
