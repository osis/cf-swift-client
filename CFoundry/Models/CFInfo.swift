import Foundation
import ObjectMapper

public class CFInfo: ImmutableMappable {
    public var support: String
    public var description: String
    public var tokenEndpoint: String
    public var authEndpoint: String
    public var apiVersion: String
    public var appSSHEndpoint: String
    public var appSSHHostKeyFingerprint: String
    public var appSSHOAuthClient: String
    public var dopplerLoggingEndpoint: String
    
    public required init(map: Map) throws {
        support = try map.value("support")
        description = try map.value("description")
        tokenEndpoint = try map.value("token_endpoint")
        authEndpoint = try map.value("authorization_endpoint")
        apiVersion = try map.value("api_version")
        appSSHEndpoint = try map.value("app_ssh_endpoint")
        appSSHHostKeyFingerprint = try map.value("app_ssh_host_key_fingerprint")
        appSSHOAuthClient = try map.value("app_ssh_oauth_client")
        dopplerLoggingEndpoint = try map.value("doppler_logging_endpoint")
    }
    
    public func mapping(map: Map) {
        support <- map["support"]
        description <- map["description"]
        tokenEndpoint <- map["token_endpoint"]
        authEndpoint <- map["authorization_endpoint"]
        apiVersion <- map["api_version"]
        appSSHEndpoint <- map["app_ssh_endpoint"]
        appSSHHostKeyFingerprint <- map["app_ssh_host_key_fingerprint"]
        appSSHOAuthClient <- map["app_ssh_oauth_client"]
        dopplerLoggingEndpoint <- map["doppler_logging_endpoint"]
    }
    
    public struct Keys {
      static let support = "support"
      static let description = "description"
      static let tokenEndpoint = "token_endpoint"
      static let authEndpoint = "authorization_endpoint"
      static let apiVersion = "api_version"
      static let appSSHEndpoint = "app_ssh_endpoint"
      static let appSSHHostKeyFingerprint = "app_ssh_host_key_fingerprint"
      static let appSSHOAuthClient = "app_ssh_oauth_client"
      static let loggingEndpoint = "logging_endpoint"
      static let dopplerLoggingEndpoint = "doppler_logging_endpoint"
    }
    
    public func serialize() -> [String : String] {
        return [
            Keys.support : support,
            Keys.description : description,
            Keys.tokenEndpoint : tokenEndpoint,
            Keys.authEndpoint : authEndpoint,
            Keys.apiVersion : apiVersion,
            Keys.appSSHEndpoint : appSSHEndpoint,
            Keys.appSSHHostKeyFingerprint : appSSHHostKeyFingerprint,
            Keys.appSSHOAuthClient : appSSHOAuthClient,
            Keys.dopplerLoggingEndpoint : dopplerLoggingEndpoint
        ]
    }
}
