import Foundation
import XCTest

@testable import CFoundry

class ServiceTests: CFModelTestBase {
    var serviceBinding: ServiceBinding?
    
    override func setUp() {
        super.setUp()
        
        serviceBinding = localResponseArray(t: ServiceBinding.self, name: "app_summary", keyPath: "services")[0]
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
