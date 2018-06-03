import Foundation
import XCTest
import Alamofire
import OHHTTPStubs
import SwiftyJSON

@testable import CFoundry

class CFApiTests: CFModelTestBase {
    
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }
    
//    func createErrorResponse(statusCode: Int) -> DataResponse<Any> {
//        let error = NSError(domain: NSExceptionName.internalInconsistencyException.rawValue, code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."])
//        let result = Result<Any>.failure(error)
//        let httpResponse = HTTPURLResponse(url: NSURL(string: "https://test.io")! as URL, statusCode: 500, httpVersion: "1.1", headerFields: nil)
//
//        return DataResponse.init(request: nil, response: httpResponse, data: nil, result: result)
//    }
    
    func testInfoSuccess() {
        let o = CFAccountFactory.info().serialize()
        stubGET(statusCode: 200, jsonObject: o)
        
        let exp = expectation(description: "Login success callback")
        CFApi.info(apiURL: "https://api.test.io", completed: { (info: CFInfo?, error: Error?) in
            XCTAssertNotNil(info)
            XCTAssertNil(error)
            exp.fulfill()
        })
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertNil(CFApi.session?.accessToken)
    }
    
    func testInfoError() {
        stubGET(statusCode: 404, jsonObject: [])
        
        let exp = expectation(description: "Login success callback")
        CFApi.info(apiURL: "https://test.io") { (info: CFInfo?, error: Error?) in
            XCTAssertNil(info)
            XCTAssertNotNil(error)
            XCTAssertTrue(error?.localizedDescription.range(of: "404") != nil)

            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertNil(CFApi.session?.accessToken)
    }

    func testLoginSuccess() {
        stubWithFile(filename: "tokens", condition: isMethodPOST())
        
        let account = CFAccountFactory.account()
        
        let exp2 = expectation(description: "Login success callback")
        CFApi.login(account: account) { error in
            XCTAssertNil(error)
            exp2.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        if let session = CFApi.session {
            XCTAssertEqual(session.accessToken, "testAccessToken")
            XCTAssertEqual(session.refreshToken, "testRefreshToken")
        } else {
            XCTFail("Session isn't set upon login")
        }
    }
    
    func testLoginError() {
        stubPOST(statusCode: 403, jsonObject: [])
        let account = CFAccountFactory.account()
        
        let exp = expectation(description: "Login success callback")
        CFApi.login(account: account) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        if CFApi.session != nil {
            XCTFail("Session should not be set after login failure.")
        }
    }
    
    func testArrayAuthTokenRefresh() {
        var callCounter = 0
        stub(condition: isMethodGET()) {_ in
            callCounter += 1
            
            if callCounter == 1 {
                return OHHTTPStubsResponse(jsonObject: [], statusCode: 401, headers: nil)
            } else if callCounter == 2 {
                let path = Bundle(for: type(of: self)).path(forResource: "orgs", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
            }
            
            XCTFail()
            return OHHTTPStubsResponse()
        }
        stubWithFile(filename: "tokens", condition: isMethodPOST())
        
        CFApi.session = CFAccountFactory.session()
        CFApi.session?.refreshToken = "refreshToken"
        CFApi.session?.accessToken = nil
        XCTAssertNil(CFApi.session?.accessToken)
        
        let exp = expectation(description: "Request auth and re-request Orgs")
        CFApi.orgs { (orgs, error) in
            XCTAssertNotNil(orgs)
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(CFApi.session?.accessToken, "testAccessToken")
        XCTAssertEqual(CFApi.session?.refreshToken, "testRefreshToken")
    }
    
    func testObjectAuthTokenRefresh() {
        var callCounter = 0
        stub(condition: isMethodGET()) {_ in
            callCounter += 1
            
            if callCounter == 1 {
                return OHHTTPStubsResponse(jsonObject: [], statusCode: 401, headers: nil)
            } else if callCounter == 2 {
                let path = Bundle(for: type(of: self)).path(forResource: "app_stats", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: [ "Content-Type": "application/json" ])
            }
            
            XCTFail()
            return OHHTTPStubsResponse()
        }
        stubWithFile(filename: "tokens", condition: isMethodPOST())
        
        CFApi.session = CFAccountFactory.session()
        CFApi.session?.refreshToken = "refreshToken"
        CFApi.session?.accessToken = nil
        XCTAssertNil(CFApi.session?.accessToken)
        
        let exp = expectation(description: "Request auth and re-request Orgs")
        CFApi.appStats(appGuid: "") { (stats, error) in
            XCTAssertNotNil(stats)
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(CFApi.session?.accessToken, "testAccessToken")
        XCTAssertEqual(CFApi.session?.refreshToken, "testRefreshToken")
    }
    
    func testOrgsSuccess() {
        let _ = stubWithFile(filename: "orgs")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Orgs success callack")
        CFApi.orgs() { orgs, error in
            XCTAssertNil(error)
            XCTAssertNotNil(orgs)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testOrgsError() {
        stubGET(statusCode: 500, jsonObject: [])
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Orgs error callack")
        CFApi.orgs() { orgs, error in
            XCTAssertNotNil(error)
            XCTAssertNil(orgs)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSpacesSuccess() {
        let _ = stubWithFile(filename: "spaces")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Spaces success callback")
        CFApi.appSpaces(appGuids: ["testGuid1","testGuid2"]) { spaces, error in
            XCTAssertNil(error)
            XCTAssertNotNil(spaces)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSpacesError() {
        stubGET(statusCode: 500, jsonObject: [])

        CFApi.session = CFAccountFactory.session()

        let exp = expectation(description: "Spaces error callback")
        CFApi.appSpaces(appGuids: ["testGuid1","testGuid2"]) { spaces, error in
            XCTAssertNotNil(error)
            XCTAssertNil(spaces)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppsSuccess() {
        let _ = stubWithFile(filename: "apps")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Apps success callback")
        CFApi.apps(orgGuid: "testGuid", page: 1, searchText: "") { apps, error in
            XCTAssertNil(error)
            XCTAssertNotNil(apps)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppsError() {
        stubGET(statusCode: 500, jsonObject: [])
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Apps error callback")
        CFApi.apps(orgGuid: "testGuid", page: 1, searchText: "") { apps, error in
            XCTAssertNotNil(error)
            XCTAssertNil(apps)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSummarySuccess() {
        stubWithFile(filename: "app_summary")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Apps summary success callback")
        CFApi.appSummary(appGuid: "testGuid") { appSummary, error in
            XCTAssertNotNil(appSummary)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSummaryError() {
        stubGET(statusCode: 500, jsonObject: [])
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Apps summary error callback")
        CFApi.appSummary(appGuid: "testGuid") { appSummary, error in
            XCTAssertNotNil(error)
            XCTAssertNil(appSummary)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppStatsSuccess() {
        stubWithFile(filename: "app_stats")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "App stats success callback")
        CFApi.appStats(appGuid: "testGuid") { appStats, error in
            XCTAssertNotNil(appStats)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppStatsError() {
        stubGET(statusCode: 500, jsonObject: [])
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "App stats success callback")
        CFApi.appStats(appGuid: "testGuid") { appStats, error in
            XCTAssertNotNil(error)
            XCTAssertNil(appStats)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppStopSuccess() {
        _ = stubWithFile(filename: "app_summary", condition: isMethodPUT())
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "App Stop success callback")
        CFApi.appStop(appGuid: "testGuid") { (app, error) in
            XCTAssertNotNil(app)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppStopError() {
        stubWithObject(statusCode: 500, jsonObject: [], isMethod: isMethodPUT())
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "App Stop error callback")
        CFApi.appStop(appGuid: "testGuid") { (app, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(app)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testEventsSuccess() {
        stubWithFile(filename: "events")
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Events success callback")
        CFApi.events(appGuid: "testGuid") { events, error in
            XCTAssertNotNil(events)
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testEventsError() {
        stubGET(statusCode: 500, jsonObject: [])
        
        CFApi.session = CFAccountFactory.session()
        
        let exp = expectation(description: "Events error callback")
        CFApi.events(appGuid: "testGuid") { events, error in
            XCTAssertNotNil(error)
            XCTAssertNil(events)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
//    func testLoginFailure() {
//        stubPOST(statusCode: 200, jsonObject: jsonObject)
//    }
    
//    func testSuccess() {
//        let result = Result<Any>.success(["testKey":"testValue"])
//        let response = DataResponse.init(request: nil, response: nil, data: nil, result: result)
//        let exp = expectation(description: "Success Callback")
//
//        CFResponseHandler().success(response, success: { json in
//            XCTAssertEqual(json["testKey"].stringValue, "testValue")
//            exp.fulfill()
//        })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//        XCTAssertNil(CFApi.session?.accessToken)
//    }
//
//    func testError() {
//        let response = createErrorResponse(statusCode: 500)
//        let exp = expectation(description: "Error Callback")
//
//        CFResponseHandler().error(response, error: { statusCode, url in
//            XCTAssertEqual(statusCode, 500)
//            XCTAssertEqual(url?.absoluteString, "https://test.io")
//
//            exp.fulfill()
//        })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//        XCTAssertNil(CFApi.session?.accessToken)
//    }
//
//    func testUnauthorizedSuccess() {
//        stub(condition: isMethodPOST()) { _ in
//            OHHTTPStubsResponse(
//                jsonObject: [],
//                statusCode: 200,
//                headers: [ "Content-Type": "application/json" ]
//            )
//        }
//        CFApi.session?.accessToken = "TestToken"
//
//        class FakeCFResponseHandler: CFResponseHandler {
//            let exp: XCTestExpectation
//            init(expectation: XCTestExpectation) {
//                self.exp = expectation
//            }
//
//            override func authRefreshSuccess(_ urlRequest: NSMutableURLRequest, success: @escaping () -> Void) {
//                XCTAssertFalse(self.retryLogin)
//                XCTAssertNil(CFApi.session?.accessToken)
//                exp.fulfill()
//            }
//        }
//
//        let account = CFAccountFactory.account()
//        //CFSession.account(account)
//        try! CFAccountStore.create(account)
//
//        let exp = expectation(description: "Auth Refresh Success Callback")
//        let handler = FakeCFResponseHandler(expectation: exp)
//        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
//
//        handler.unauthorized(request, success: {  })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//
//        try! CFAccountStore.delete(account)
//    }
//
//    func testUnauthorizedFailure() {
//        stub(condition: isMethodGET()) { _ in
//            OHHTTPStubsResponse(
//                jsonObject: [],
//                statusCode: 401,
//                headers: [ "Content-Type": "application/json" ]
//            )}
//
//        class FakeCFResponseHandler: CFResponseHandler {
//            let exp: XCTestExpectation
//            init(exp: XCTestExpectation) {
//                self.exp = exp
//            }
//
//            override func authRefreshFailure() {
//                exp.fulfill()
//            }
//        }
//
//        let account = CFAccountFactory.account()
//        //CFSession.account(account)
//        try! CFAccountStore.create(account)
//
//        let exp = expectation(description: "Auth Refresh Success Callback")
//        let handler = FakeCFResponseHandler(exp: exp)
//        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
//
//        handler.unauthorized(request, success: { })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//    }
//
//    func testUnauthorizedWithNoCreds() {
//        class FakeCFResponseHandler: CFResponseHandler {
//            let exp: XCTestExpectation
//            init(exp: XCTestExpectation) {
//                self.exp = exp
//            }
//
//            override func authRefreshFailure() {
//                exp.fulfill()
//            }
//        }
//
//        let exp = expectation(description: "Auth Refresh Success Callback")
//        let handler = FakeCFResponseHandler(exp: exp)
//        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
//
//        handler.unauthorized(request, success: { })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//    }
//
//
//    func testAuthRefreshSuccess() {
//        stub(condition: isMethodGET()) { _ in
//            OHHTTPStubsResponse(
//                jsonObject: [],
//                statusCode: 200,
//                headers: [ "Content-Type": "application/json" ]
//            )}
//
//        let handler = CFResponseHandler()
//        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
//        let exp = expectation(description: "Auth Recovery Success Callback")
//
//        handler.retryLogin = false
//        handler.authRefreshSuccess(request, success: {
//            exp.fulfill()
//        })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//
//        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
//        XCTAssertTrue(handler.retryLogin)
//    }
//
//    func testAuthRefreshSuccessWithToken() {
//        stub(condition: isMethodGET()) { _ in
//            OHHTTPStubsResponse(
//                jsonObject: [],
//                statusCode: 200,
//                headers: [ "Content-Type": "application/json" ]
//            )}
//
//        let handler = CFResponseHandler()
//        let request = NSMutableURLRequest(url: URL(string: "https://api.test.io")!)
//        let exp = expectation(description: "Auth Recovery Success Callback")
//
//        CFApi.session?.accessToken = "TestToken"
//        handler.authRefreshSuccess(request, success: {
//            exp.fulfill()
//        })
//
//        waitForExpectations(timeout: 1.0, handler: nil)
//        let authHeaderToken = request.value(forHTTPHeaderField: "Authorization")
//        XCTAssertEqual(authHeaderToken, "Bearer TestToken")
//    }
}
