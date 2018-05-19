Pod::Spec.new do |s|
  s.name          = 'CFoundry'
  s.version       = '0.0.1'
  s.license       = { :type => 'Apache License, Version 2.0' }
  s.homepage      = 'https://github.com/osis/cf-ios-sdk'
  s.authors       = { 'Dwayne Forde' => 'dwayne.forde@gmail.com' }
  s.summary       = 'A Cloud Foundry SDK for Cocoa Applications'
  s.swift_version = '3.3'

  s.ios.deployment_target  = '9.0'

  s.source        = { :git => 'https://github.com/osis/cf-ios-sdk.git', :tag => s.version.to_s }
  s.source_files  = 'CFoundry/**/*.swift'

  s.dependency 'Alamofire', '~> 4.7.2'
  s.dependency 'SwiftyJSON', '~> 3.1.4'
  s.dependency 'SwiftWebSocket', '~> 2.7.0'
  s.dependency 'ProtocolBuffers-Swift', '3.0.22'
  s.dependency 'Locksmith', '~> 3.0.0'
  s.dependency 'AlamofireObjectMapper', '~> 5.0.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'CFoundryTests/**/*.swift'
    test_spec.dependency 'OHHTTPStubs', '~> 6.1.0'
  end
end
