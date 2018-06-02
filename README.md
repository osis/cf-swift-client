# CFoundry: Cloud Foundry Swift Client
[![Build Status](https://travis-ci.org/osis/cf-swift-client.svg?branch=master)](https://travis-ci.org/osis/cf-swift-client) [![codebeat badge](https://codebeat.co/badges/0d77c411-7bc1-403b-98fd-855add993248)](https://codebeat.co/projects/github-com-osis-cf-swift-sdk-master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![CocoaPods](https://img.shields.io/cocoapods/v/CFoundry.svg) ![Platform](https://img.shields.io/badge/platforms-iOS%209.0+-333333.svg)

## Features

- Compatible with Cloud Foundry v2 API
- Ability to list Organizations, Spaces, and Applications
- Details such Application Summary, Service Bindings, Instance information, and Events
- Recent & Realtime Application Log Streaming

## Installation

#### CocoaPods

You can use [CocoaPods](http://cocoapods.org/) to install `CFoundry` by adding it to your `Podfile`:

```ruby
use_frameworks!

target 'MyApp' do
    pod 'CFoundry'
end
```

#### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install `CFoundry` by adding it to your `Cartfile`:

```
github "osis/cf-swift-sdk"
```

If you use Carthage to build your dependencies, make sure you have added `CFoundry.framework` to the "Linked Frameworks and Libraries" section of your target, and have included them in your Carthage framework copying build phase.

## Sample
```swift
CFApi.info(apiURL: urlString) { (info: CFInfo?, error: Error?) in
    if let e = error {
        return
    }
    
    if let i = info {
      print(i.apiVersion)
    }
}
```

## In Use

[CF Apps IOS](https://github.com/osis/cf-apps-ios)
