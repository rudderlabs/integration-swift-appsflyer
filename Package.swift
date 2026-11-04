// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "RudderIntegrationAppsFlyer",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
    products: [.library(name: "RudderIntegrationAppsFlyer", targets: ["RudderIntegrationAppsFlyer"])],
    dependencies: [.package(url: "https://github.com/rudderlabs/rudder-sdk-swift.git", from: "2.0.0"), .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework-Static", .upToNextMajor(from: "7.0.1"))],
    targets: [.target(name: "RudderIntegrationAppsFlyer", dependencies: [.product(name: "RudderStackAnalytics", package: "rudder-sdk-swift"), .product(name: "AppsFlyerLib-Static", package: "appsflyerframework-static")])]
)
