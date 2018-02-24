import Foundation
import XCTest
import OHHTTPStubs
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

@testable import CFoundry

class CFModelTestBase: XCTestCase {
    func localResponseArray<T: ImmutableMappable>(t: T.Type, name: String, keyPath: String = "resources") -> [T] {
        let path = Bundle(for: type(of: self)).path(forResource: name, ofType: "json")
        let responseStub = stub(condition: isMethodGET()) { _ in
            OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
        }
        
        var spaces:[T] = []
        let exp = expectation(description: "moo")
        Alamofire.request("test.io/local").responseArray(queue: nil, keyPath: keyPath, context: nil) { (response: DataResponse<[T]>) in
            spaces = response.result.value!
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        OHHTTPStubs.removeStub(responseStub)
        
        return spaces
    }
    
    func localResponseObject<T: ImmutableMappable>(t: T.Type, name: String) -> T {
        let path = Bundle(for: type(of: self)).path(forResource: name, ofType: "json")
        let responseStub = stub(condition: isMethodGET()) { _ in
            OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
        }
        
        var object:T?
        let exp = expectation(description: "moo")
        Alamofire.request("test.io/local").responseObject(queue: nil, keyPath: nil, context: nil) { (response: DataResponse<T>) in
            object = response.result.value!
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        OHHTTPStubs.removeStub(responseStub)
        
        return object!
    }
    
    func testResponseArray() {
        let spaces = self.localResponseArray(t: CFSpace.self, name: "spaces")
        
        XCTAssertEqual(spaces.count, 7)
        XCTAssertEqual(OHHTTPStubs.allStubs().count, 0)
    }
    
    func testResponseObject() {
        let info = self.localResponseObject(t: CFInfo.self, name: "info")
        
        XCTAssertNotNil(info)
        XCTAssertEqual(OHHTTPStubs.allStubs().count, 0)
    }
}
