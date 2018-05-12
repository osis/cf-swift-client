import Foundation
import XCTest

@testable import CFoundry

class CFAppSummaryTests: CFModelTestBase {
    var appSummary: CFApp?
    
    override func setUp() {
        super.setUp()
        
        appSummary = localResponseObject(t: CFApp.self, name: "app_summary", keyPath: "")
    }
    
    func testServicesPresence() {
        if let services = appSummary?.serviceBindings {
            XCTAssertNotNil(services)
            XCTAssertEqual(services.count, 1)
        } else {
            XCTFail("No services found/parsed.")
        }
    }
    
    func testRoutesPresence() {
    }
}
