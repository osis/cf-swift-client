import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper
import AlamofireObjectMapper

enum CFAPIError: Error, CustomStringConvertible {
    case NullAccountError()
    
    var description: String {
        switch self {
        case .NullAccountError:
            return "There is no account set to CFAPI."
        }
    }
}

public class CFApi {
    
    static var session: CFSession?
    
    public static func info(apiURL: String, completed: @escaping (_ info: CFInfo?, _ error: Error?) -> Void) {
        let infoRequest = CFRequest.info(apiURL)
        
        performObjectRequest(t: CFInfo.self, cfRequest: infoRequest, completed: completed)
    }
    
    public static func login(account: CFAccount, completed: @escaping (Error?) -> Void) {
        self.session = CFSession(account: account)
        
        performAuthRequest(account: account, completed: completed)
    }
    
    public static func logout() {
        session = nil
        
        Alamofire.SessionManager.default.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
    public static func orgs(completed: @escaping (_ orgs: [CFOrg]?, _ error: Error?) -> Void) {
        let orgsRequest = CFRequest.orgs()
        
        performArrayRequest(t: CFOrg.self, cfRequest: orgsRequest, completed: completed)
    }
    
    public static func appSpaces(appGuids: [String], completed: @escaping (_ spaces: [CFSpace]?, _ error: Error?) -> Void) {
        let spacesRequest = CFRequest.appSpaces(appGuids)
        
        performArrayRequest(t: CFSpace.self, cfRequest: spacesRequest, completed: completed)
    }
    
    public static func apps(orgGuid: String, page: Int, searchText: String, completed: @escaping (_ apps: [CFApp]?, _ error: Error?) -> Void) {
        let appsRequest = CFRequest.apps(orgGuid, page, searchText)
        
        performArrayRequest(t: CFApp.self, cfRequest: appsRequest, completed: completed)
    }
    
    public static func appSummary(appGuid: String, completed: @escaping (_ appSummary: CFApp?, _ error: Error?) -> Void) {
        let appSummaryRequest = CFRequest.appSummary(appGuid)
        
        performObjectRequest(t: CFApp.self, cfRequest: appSummaryRequest, completed: completed)
    }
    
    public static func appStats(appGuid: String, completed: @escaping (_ appStats: CFAppStats?, _ error: Error?) -> Void) {
        let appStatsRequest = CFRequest.appStats(appGuid)
        
        performObjectRequest(t: CFAppStats.self, cfRequest: appStatsRequest, completed: completed)
    }
    
    public static func events(appGuid: String, completed: @escaping (_ appStats: [CFEvent]?, _ error: Error?) -> Void) {
        let eventsRequest = CFRequest.events(appGuid)
        
        performArrayRequest(t: CFEvent.self, cfRequest: eventsRequest, completed: completed)
    }
    
    public static func recentLogs(appGuid: String, completed: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Void) {
        let recentLogsRequest = CFRequest.recentLogs(appGuid)
        
        Alamofire.request(recentLogsRequest.urlRequest!).validate().responseData() { response in
            if (response.response?.statusCode == 401) {
                performAuthRefreshRequest() {
                    CFApi.recentLogs(appGuid: appGuid, completed: completed)
                }
                return;
            }
            completed(response.response, response.data, response.error)
        }
    }
    
    public static func performAuthRefreshRequest(success: @escaping () -> Void) {
        print("** CFApi: Refeshing Token...")
        if let session = CFApi.session, let token = session.refreshToken {
            let request = CFRequest.tokenRefresh(session.info.authEndpoint, token)
            Alamofire.request(request).validate().responseJSON(queue: nil, options: []) { response in
                if let error = response.error {
                    self.session = nil
                    // completed(nil, error)
                    // TODO: authfail callback
                    return;
                }
                
                if let json = response.value as? [String : AnyObject] {
                    print("** CFApi: Retrying Original Request...")
                    self.session?.accessToken = json["access_token"] as? String
                    self.session?.refreshToken = json["refresh_token"] as? String
                    success()
                }
            }
        }
    }
}
    
private extension CFApi {

    static func performObjectRequest<T: ImmutableMappable>(t: T.Type, cfRequest: CFRequest, completed: @escaping (T?, Error?) -> Void) {
        Alamofire.request(cfRequest.urlRequest!).validate().responseObject(queue: nil, keyPath: cfRequest.keypath, context: nil) { (response: DataResponse<T>) in
            print("** CFApi: Requesting \(T.self)...")
            if (response.response?.statusCode == 401) {
                performAuthRefreshRequest() {
                    performObjectRequest(t: T.self, cfRequest: cfRequest, completed: completed)
                }
                return;
            }
            completed(response.result.value, response.error)
        }
    }
    
    static func performArrayRequest<T: ImmutableMappable>(t: T.Type, cfRequest: CFRequest, completed: @escaping ([T]?, Error?) -> Void) {
        Alamofire.request(cfRequest.urlRequest!).validate().responseArray(queue: nil, keyPath: cfRequest.keypath, context: nil) { (response: DataResponse<[T]>) in
            print("** CFApi: Requesting \(T.self)...")
            if (response.response?.statusCode == 401) {
                performAuthRefreshRequest() {
                    performArrayRequest(t: T.self, cfRequest: cfRequest, completed: completed)
                }
                return;
            }
            completed(response.result.value, response.error)
        }
    }
    
    static func performAuthRequest(account: CFAccount, completed: @escaping (Error?) -> Void) {
        let request = CFRequest.tokenGrant(account.info.authEndpoint, account.username, account.password)

        Alamofire.request(request).validate().responseJSON(queue: nil, options: []) { response in
            if let error = response.error {
                self.session = nil
                completed(error)
                return;
            }

            if let json = response.value as? [String : AnyObject] {
                self.session?.accessToken = json["access_token"] as? String
                self.session?.refreshToken = json["refresh_token"] as? String
                completed(nil)
            }
        }
    }
    
    static func dopplerRequest(_ urlRequest: URLRequestConvertible, completionHandler: @escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {

        Alamofire.request(urlRequest.urlRequest!).validate().responseData(completionHandler: { (response) in
            completionHandler(response.request, response.response, response.data, response.error as NSError?)
        })
    }
}
