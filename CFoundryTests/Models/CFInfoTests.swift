import Foundation
import XCTest

@testable import CFoundry

class CFInfoTests: CFModelTestBase {
    var info: CFInfo?

    override func setUp() {
        super.setUp()
        
        info = localResponseObject(t: CFInfo.self, name: "info")
    }

    func testProperties() {
        if let info = self.info {
            XCTAssertEqual(info.apiVersion, "2.57.0")
            XCTAssertEqual(info.support, "http://support.cloudfoundry.com")
            XCTAssertEqual(info.description, "Cloud Foundry")
            XCTAssertEqual(info.authEndpoint, "https://login.test.io")
            XCTAssertEqual(info.tokenEndpoint, "https://uaa.test.io")
            XCTAssertEqual(info.apiVersion, "2.57.0")
            XCTAssertEqual(info.appSSHEndpoint, "ssh.test.io:2222")
            XCTAssertEqual(info.appSSHHostKeyFingerprint, "11:22:33:44:55:66:77:88:99:00:a1:a2:a3")
            XCTAssertEqual(info.appSSHOAuthClient, "ssh-proxy")
            XCTAssertEqual(info.dopplerLoggingEndpoint, "wss://doppler.test.io:443")
        } else {
            XCTFail()
        }
    }

    func testSerialize() {
        if let info = self.info {
            XCTAssertEqual(info.serialize(), [
                "support" : "http://support.cloudfoundry.com",
                "description" : "Cloud Foundry",
                "authorization_endpoint" : "https://login.test.io",
                "token_endpoint" : "https://uaa.test.io",
                "api_version" : "2.57.0",
                "app_ssh_endpoint" : "ssh.test.io:2222",
                "app_ssh_host_key_fingerprint" : "11:22:33:44:55:66:77:88:99:00:a1:a2:a3",
                "app_ssh_oauth_client" : "ssh-proxy",
                "doppler_logging_endpoint" : "wss://doppler.test.io:443"
            ])
        } else {
            XCTFail()
        }
    }
}
