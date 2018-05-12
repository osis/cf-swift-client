import Foundation
import XCTest
import OHHTTPStubs
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

@testable import CFoundry

class CFModelTestBase: XCTestCase {
    override func tearDown() {
        super.tearDown()
        
        CFApi.session = nil
    }
    
    func localResponseArray<T: ImmutableMappable>(t: T.Type, name: String, keyPath: String = "resources") -> [T] {
        let responseStub = stubWithFile(filename: name)
        
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
    
    func localResponseObject<T: ImmutableMappable>(t: T.Type, name: String, keyPath: String? = nil) -> T {
        let responseStub = stubWithFile(filename: name)
        
        var object:T?
        let exp = expectation(description: "moo")
        Alamofire.request("test.io/local").responseObject(queue: nil, keyPath: keyPath, context: nil) { (response: DataResponse<T>) in
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
    
    func stubPOST(statusCode: Int32, jsonObject: Any) {
        stubWithObject(statusCode: statusCode, jsonObject: jsonObject, isMethod: isMethodPOST())
    }
    
    func stubGET(statusCode: Int32, jsonObject: Any) {
        stubWithObject(statusCode: statusCode, jsonObject: jsonObject, isMethod: isMethodGET())
    }
    
    func stubWithObject(statusCode: Int32, jsonObject: Any, isMethod: @escaping OHHTTPStubsTestBlock) {
        stub(condition: isMethod) { _ in
            OHHTTPStubsResponse(
                jsonObject: jsonObject,
                statusCode: statusCode,
                headers: [ "Content-Type": "application/json" ]
            )
        }
    }
    
    func stubWithFile(filename: String, condition: @escaping OHHTTPStubsTestBlock = isMethodGET()) -> OHHTTPStubsDescriptor {
        let path = Bundle(for: type(of: self)).path(forResource: filename, ofType: "json")
        return stub(condition: condition) { _ in
            OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
        }
    }
}
