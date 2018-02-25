import Foundation
import XCTest

@testable import CFoundry

class CFServiceBindingTests: CFModelTestBase {
    var serviceBinding: CFServiceBinding?
    
    override func setUp() {
        super.setUp()
        
        serviceBinding = localResponseArray(t: CFServiceBinding.self, name: "app_summary", keyPath: "services")[0]
    }
    
    func testName() {
        XCTAssertEqual(serviceBinding!.name, "name-82")
    }
    
    func testServiceLabel() {
        XCTAssertEqual(serviceBinding!.serviceLabel, "label-1")
    }
    
    func testPlanName() {
        XCTAssertEqual(serviceBinding!.planName, "name-83")
    }
}
