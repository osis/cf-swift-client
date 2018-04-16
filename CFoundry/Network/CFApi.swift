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
    
    static func info(apiURL: String, completed: @escaping (_ info: CFInfo?, _ error: Error?) -> Void) {
        let infoRequest = CFRequest.info(apiURL)
        
        performObjectRequest(t: CFInfo.self, cfRequest: infoRequest, completed: completed)
    }
    
    static func login(account: CFAccount, completed: @escaping (Error?) -> Void) {
        self.session = CFSession(account: account)
        performAuthRequest(account: account, completed: completed)
    }
    
    static func orgs(completed: @escaping (_ orgs: [CFOrg]?, _ error: Error?) -> Void) {
        let orgsRequest = CFRequest.orgs()
        
        performArrayRequest(t: CFOrg.self, cfRequest: orgsRequest, completed: completed)
    }
    
    static func apps(orgGuid: String, page: Int, searchText: String, completed: @escaping (_ orgs: [CFApp]?, _ error: Error?) -> Void) {
        let orgsRequest = CFRequest.apps(orgGuid, page, searchText)
        
        performArrayRequest(t: CFApp.self, cfRequest: orgsRequest, completed: completed)
    }
    
    static func spaces(completed: @escaping (_ spaces: [CFSpace]?, _ error: Error?) -> Void) {
        let spacesRequest = CFRequest.orgs()
        
        performArrayRequest(t: CFSpace.self, cfRequest: spacesRequest, completed: completed)
    }
}
    
private extension CFApi {
    
    static func performObjectRequest<T: ImmutableMappable>(t: T.Type, cfRequest: CFRequest, completed: @escaping (T?, Error?) -> Void) {
        Alamofire.request(cfRequest.urlRequest!).validate().responseObject(queue: nil, keyPath: cfRequest.keypath, context: nil) { (response: DataResponse<T>) in
            completed(response.result.value, response.error)
        }
    }
    
    static func performArrayRequest<T: ImmutableMappable>(t: T.Type, cfRequest: CFRequest, completed: @escaping ([T]?, Error?) -> Void) {
        Alamofire.request(cfRequest.urlRequest!).validate().responseArray(queue: nil, keyPath: cfRequest.keypath, context: nil) { (response: DataResponse<[T]>) in
            print("** CFApi: Requesting \(T.self)...")
            if (response.response?.statusCode == 401) {
                performAuthRefreshRequest(t: T.self, request: cfRequest, completed: completed)
                return;
            }
            completed(response.result.value, response.error)
        }
    }
        
    // custom unauthorized callback closure?
       
    static func performAuthRefreshRequest<T: ImmutableMappable>(t: T.Type, request: CFRequest, completed: @escaping ([T]?, Error?) -> Void) {
        print("** CFApi: Refeshing Token...")
        if let token = CFApi.session?.refreshToken {
            let request = CFRequest.tokenRefresh(token)
            Alamofire.request(request).validate().responseJSON(queue: nil, options: []) { response in
                if let error = response.error {
                    self.session = nil
                    completed(nil, error)
                    return;
                }
                
                if let json = response.value as? [String : AnyObject] {
                    print("** CFApi: Retrying Original Request...")
                    self.session?.accessToken = json["access_token"] as? String
                    self.session?.refreshToken = json["refresh_token"] as? String
                    performArrayRequest(t: T.self, cfRequest: request, completed: completed)
                }
            }
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
    
    
    
//    public func dopplerRequest(_ urlRequest: URLRequestConvertible, completionHandler: @escaping (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: NSError?) -> Void) {
//
//        Alamofire.request(urlRequest.urlRequest!).validate().responseData(completionHandler: { (response) in
//            completionHandler(response.request, response.response, response.data, response.error as NSError?)
//        })
//    }
//
//    func refreshToken(_ loginURLRequest: CFRequest, originalURLRequest: NSMutableURLRequest, success: @escaping () -> Void) {
//            self.request(loginURLRequest, success: { _ in
//                print("--- Token Refresh Success")
//                self.responseHandler.authRefreshSuccess(originalURLRequest, success: success)
//            }, error: { (_, _) in
//                print("--- Token Refresh Fail")
//                self.responseHandler.authRefreshFailure()
//        })
//    }
//
//    func handleResponse(_ response: DataResponse<Any>, success: @escaping () -> Void, error: @escaping (_ statusCode: Int?, _ url: URL?) -> Void) {
//        if (response.result.isSuccess) {
//            responseHandler.success(response, success: success)
//        } else if (response.response?.statusCode == 401 && responseHandler.retryLogin) {
//            print("--- Auth Fail")
//            responseHandler.unauthorized(response.request!.urlRequest as! NSMutableURLRequest, success: success)
//        } else if (response.result.isFailure) {
//            print("--- Error")
//            responseHandler.error(response, error: error)
//        }
//    }
}
