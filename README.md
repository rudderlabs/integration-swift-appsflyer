<p align="center">
  <a href="https://rudderstack.com/">
    <img alt="RudderStack" width="512" src="https://raw.githubusercontent.com/rudderlabs/rudder-sdk-js/develop/assets/rs-logo-full-light.jpg">
  </a>
  <br />
  <caption>The Customer Data Platform for Developers</caption>
</p>
<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://rudderstack.com/docs/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Community Slack</a>
  </b>
</p>

---


# AppsFlyer Integration

The AppsFlyer integration allows you to send your event data from RudderStack to AppsFlyer for mobile measurement and user acquisition.

## Installation

### Swift Package Manager

Add the AppsFlyer integration to your Swift project using Swift Package Manager:

1. In Xcode, go to `File > Add Package Dependencies`

  <img width="960" height="540" alt="add_package_dependency" src="https://github.com/user-attachments/assets/56f2673c-127b-4766-b570-c07523c6bda4" />

2. Enter the package repository URL: `https://github.com/rudderlabs/integration-swift-appsflyer` in the search bar
3. Select the version you want to use

  <img width="806" height="440" alt="select_package" src="https://github.com/user-attachments/assets/639884c1-b094-445e-b659-d8e4c1f09156" />

4. Select the target to which you want to add the package
5. Finally, click on **Add Package**

   <img width="643" height="282" alt="select_trget" src="https://github.com/user-attachments/assets/78837ba6-faa7-4e6d-b030-b02cb12ba2a1" />

Alternatively, add it to your `Package.swift` file:

```swift
// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YourApp",
    products: [
        .library(
            name: "YourApp",
            targets: ["YourApp"]),
    ],
    dependencies: [
        // Add the AppsFlyer integration
        .package(url: "https://github.com/rudderlabs/integration-swift-appsflyer.git", .upToNextMajor(from: "<latest_version>"))
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "RudderIntegrationAppsFlyer", package: "integration-swift-appsflyer")
            ]),
    ]
)
```

## Supported Native AppsFlyer SDK Version

This integration supports AppsFlyer iOS SDK version:

```
6.17.0+
```

### Platform Support

The integration supports the following platforms:
- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+

## Usage

Initialize the RudderStack SDK and add the AppsFlyer integration:

```swift
import RudderStackAnalytics
import RudderIntegrationAppsFlyer

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize the RudderStack Analytics SDK
        let config = Configuration(
            writeKey: "<WRITE_KEY>",
            dataPlaneUrl: "<DATA_PLANE_URL>"
        )
        let analytics = Analytics(configuration: config)

        // Add AppsFlyer integration
        analytics.add(plugin: AppsFlyerIntegration())

        return true
    }
}
```

Replace:
- `<WRITE_KEY>`: Your project's write key from the RudderStack dashboard
- `<DATA_PLANE_URL>`: The URL of your RudderStack data plane

---

## Contact us

For more information:

- Email us at [docs@rudderstack.com](mailto:docs@rudderstack.com)
- Join our [Community Slack](https://rudderstack.com/join-rudderstack-slack-community)

## Follow Us

- [RudderStack Blog](https://rudderstack.com/blog/)
- [Slack](https://rudderstack.com/join-rudderstack-slack-community)
- [Twitter](https://twitter.com/rudderstack)
- [YouTube](https://www.youtube.com/channel/UCgV-B77bV_-LOmKYHw8jvBw)
