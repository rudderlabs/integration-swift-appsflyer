//
//  AppsFlyerExampleApp.swift
//  AppsFlyerExample
//
//  Created by Vishal Gupta on 26/11/25.
//

import SwiftUI
import Combine
import RudderStackAnalytics
import RudderIntegrationAppsFlyer
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

@main
struct AppsFlyerExampleApp: App {

    init() {
        setupAppsFlyer()
        setupAnalytics()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    startAppsFlyer()
                    requestTrackingPermission()
                }
        }
    }

    private func setupAppsFlyer() {
        LoggerAnalytics.logLevel = .verbose
        // Log device IDFV for debugging
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            LoggerAnalytics.debug("Device IDFV: \(idfv)")
        } else {
            LoggerAnalytics.debug("Device IDFV: Not available")
        }
        
        // Initialize AppsFlyer SDK first (before Analytics)
        AppsFlyerLib.shared().appsFlyerDevKey = "<YOUR_APPSFLYER_DEV_KEY>"
        AppsFlyerLib.shared().appleAppID = "<YOUR_APPLE_APP_ID>"
        AppsFlyerLib.shared().isDebug = true
        
        // Wait for ATT user authorization with timeout
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
    }

    private func setupAnalytics() {

        // Configuration for RudderStack Analytics
        let configuration = Configuration(writeKey: "<YOUR_WRITE_KEY>", dataPlaneUrl: "<YOUR_DATA_PLANE_URL>")

        // Initialize Analytics
        let analytics = Analytics(configuration: configuration)

        // Add AppsFlyer Integration
        let appsFlyerIntegration = AppsFlyerIntegration()
        analytics.add(plugin: appsFlyerIntegration)

        // Store analytics instance globally for access in ContentView
        AnalyticsManager.shared.analytics = analytics
    }

    private func startAppsFlyer() {
        AppsFlyerLib.shared().start()
    }

    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                LoggerAnalytics.debug("ATT Status: \(status.rawValue)")
                switch status {
                case .authorized:
                    LoggerAnalytics.debug("Tracking authorized")
                case .denied:
                    LoggerAnalytics.debug("Tracking denied")
                case .notDetermined:
                    LoggerAnalytics.debug("Tracking not determined")
                case .restricted:
                    LoggerAnalytics.debug("Tracking restricted")
                @unknown default:
                    LoggerAnalytics.debug("Unknown tracking status")
                }
            }
        }
    }
}

// Singleton to manage analytics instance
class AnalyticsManager {
    static let shared = AnalyticsManager()
    var analytics: Analytics?

    private init() {}
}

extension AnalyticsManager {

    // MARK: - User Identity

    func identifyUser() {
        let traits: [String: Any] = [
            "email": "test@gmail.com",
            "firstname": "First Name",
            "lastname": "Last Name",
            "phone": "0123456789",
            "gender": "Male",
            "birthday": Date(),
            "address": [
                "city": "Kolkata",
                "country": "India"
            ],
            "key-1": "value-1",
            "key-2": 1234
        ]

        analytics?.identify(userId: "test_userid_ios", traits: traits)
        LoggerAnalytics.debug("✅ Identified user with traits")
    }

    func identifyUserSimple() {
        analytics?.identify(userId: "test_userid_ios")
        LoggerAnalytics.debug("✅ Identified user (simple)")
    }

    func aliasUser() {
        analytics?.alias(newId: "test_userid_ios_2")
        LoggerAnalytics.debug("✅ Aliased user")
    }

    // MARK: - Custom Events

    func customTrackEvent() {
        let properties: [String: Any] = [
            "key_1": "value_1",
            "key_2": "value_2"
        ]
        analytics?.track(name: "New Track event", properties: properties)
        LoggerAnalytics.debug("✅ Tracked custom event")
    }

    // MARK: - Search Events

    func productsSearchedEvent() {
        let properties: [String: Any] = [
            "query": "HDMI cable"
        ]
        analytics?.track(name: "Products Searched", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Products Searched event")
    }

    // MARK: - Product List Events

    func productListViewedEvent() {
        let product1: [String: Any] = [
            "product_id": "223344ffdds3ff3",
            "sku": "12345",
            "name": "Just Another Game",
            "price": 22,
            "position": 2,
            "category": "Games and Entertainment",
            "url": "https://www.myecommercewebsite.com/product",
            "image_url": "https://www.myecommercewebsite.com/product/path.jpg"
        ]
        
        let product2: [String: Any] = [
            "product_id": "343344ff5567ff3",
            "sku": "12346",
            "name": "Wrestling Trump Cards",
            "price": 4,
            "position": 21,
            "category": "Card Games"
        ]
        
        let properties: [String: Any] = [
            "list_id": "list1",
            "category": "What's New",
            "products": [product1, product2]
        ]
        
        analytics?.track(name: "Product List Viewed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product List Viewed event")
    }

    // MARK: - Single Product Events

    func productViewedEvent() {
        let properties: [String: Any] = [
            "product_id": "123",
            "sku": "F15",
            "category": "Games",
            "name": "Game",
            "brand": "Gamepro",
            "variant": "111",
            "price": 13.49,
            "quantity": 11,
            "coupon": "DISC21",
            "currency": "USD",
            "position": 1,
            "url": "https://www.website.com/product/path",
            "image_url": "https://www.website.com/product/path.png"
        ]
        
        analytics?.track(name: "Product Viewed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Viewed event")
    }

    func productAddedToWishlistEvent() {
        let properties: [String: Any] = [
            "wishlist_id": "12345",
            "wishlist_name": "Games",
            "product_id": "235564423234",
            "sku": "F-17",
            "category": "Games",
            "name": "Cards",
            "brand": "Imagepro",
            "variant": "123",
            "price": 8.99,
            "quantity": 1,
            "coupon": "COUPON",
            "position": 1,
            "url": "https://www.site.com/product/path",
            "image_url": "https://www.site.com/product/path.jpg"
        ]
        
        analytics?.track(name: "Product Added to Wishlist", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Added to Wishlist event")
    }

    func productAddedEvent() {
        let properties: [String: Any] = [
            "product_id": "123",
            "sku": "F15",
            "category": "Games",
            "name": "Game",
            "brand": "Gamepro",
            "variant": "111",
            "price": 13.49,
            "quantity": 11,
            "coupon": "DISC21",
            "position": 1,
            "url": "https://www.website.com/product/path",
            "image_url": "https://www.website.com/product/path.png"
        ]
        
        analytics?.track(name: "Product Added", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Added event")
    }

    func productRemovedEvent() {
        let properties: [String: Any] = [
            "product_id": "123",
            "sku": "F15",
            "category": "Games",
            "name": "Game",
            "brand": "Gamepro",
            "variant": "111",
            "price": 13.49,
            "quantity": 11,
            "coupon": "DISC21",
            "position": 1,
            "url": "https://www.website.com/product/path",
            "image_url": "https://www.website.com/product/path.png"
        ]
        
        analytics?.track(name: "Product Removed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Removed event")
    }

    // MARK: - Checkout Events

    func checkoutStartedEvent() {
        let product1: [String: Any] = [
            "product_id": "123",
            "sku": "G-32",
            "name": "Monopoly",
            "price": 14,
            "quantity": 1,
            "category": "Games",
            "url": "https://www.website.com/product/path",
            "image_url": "https://www.website.com/product/path.jpg"
        ]
        
        let product2: [String: Any] = [
            "product_id": "345",
            "sku": "F-32",
            "name": "UNO",
            "price": 3.45,
            "quantity": 2,
            "category": "Games"
        ]
        
        let properties: [String: Any] = [
            "order_id": "1234",
            "affiliation": "Apple Store",
            "value": 20,
            "revenue": 15.0,
            "shipping": 4,
            "tax": 1,
            "discount": 1.5,
            "coupon": "ImagePro",
            "currency": "USD",
            "products": [product1, product2]
        ]
        
        analytics?.track(name: "Checkout Started", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Checkout Started event")
    }

    func orderCompletedEvent() {
        let product1: [String: Any] = [
            "product_id": "123",
            "sku": "G-32",
            "name": "Monopoly",
            "price": 14,
            "quantity": 1,
            "category": "Games",
            "url": "https://www.website.com/product/path",
            "image_url": "https://www.website.com/product/path.jpg"
        ]
        
        let product2: [String: Any] = [
            "product_id": "345",
            "sku": "F-32",
            "name": "UNO",
            "price": 3.45,
            "quantity": 2,
            "category": "Games"
        ]
        
        let properties: [String: Any] = [
            "checkout_id": "12345",
            "order_id": "1234",
            "affiliation": "Apple Store",
            "total": 20,
            "revenue": 15.0,
            "shipping": 4,
            "tax": 1,
            "discount": 1.5,
            "coupon": "ImagePro",
            "currency": "USD",
            "products": [product1, product2]
        ]
        
        analytics?.track(name: "Order Completed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Order Completed event")
    }

    // MARK: - Promotion Events

    func promotionViewedEvent() {
        let properties: [String: Any] = [
            "promotion_id": "promo1",
            "creative": "banner1",
            "name": "sale",
            "position": "home_top"
        ]
        
        analytics?.track(name: "Promotion Viewed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Promotion Viewed event")
    }

    func promotionClickedEvent() {
        let properties: [String: Any] = [
            "promotion_id": "promo1",
            "creative": "banner1",
            "name": "sale",
            "position": "home_top"
        ]
        
        analytics?.track(name: "Promotion Clicked", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Promotion Clicked event")
    }

    // MARK: - Payment and Sharing Events

    func paymentInfoEnteredEvent() {
        let properties: [String: Any] = [
            "checkout_id": "12344",
            "order_id": "123"
        ]
        
        analytics?.track(name: "Payment Info Entered", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Payment Info Entered event")
    }

    func productSharedEvent() {
        let properties: [String: Any] = [
            "share_via": "SMS",
            "share_message": "Check this",
            "recipient": "name@friendsemail.com",
            "product_id": "12345872254426",
            "sku": "F-13",
            "category": "Games",
            "name": "Cards",
            "brand": "Maples",
            "variant": "150s",
            "price": 15.99,
            "url": "https://www.myecommercewebsite.com/product/prod",
            "image_url": "https://www.myecommercewebsite.com/product/prod.jpg"
        ]
        
        analytics?.track(name: "Product Shared", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Shared event")
    }

    func cartSharedEvent() {
        let properties: [String: Any] = [
            "share_via": "SMS",
            "share_message": "Check this",
            "recipient": "friend@friendsemail.com",
            "cart_id": "1234df2ddss",
            "products": [
                ["product_id": "125"],
                ["product_id": "297"]
            ]
        ]
        
        analytics?.track(name: "Cart Shared", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Cart Shared event")
    }

    func productReviewedEvent() {
        let properties: [String: Any] = [
            "product_id": "12345",
            "review_id": "review12",
            "review_body": "Good product, delivered in excellent condition",
            "rating": "5"
        ]
        
        analytics?.track(name: "Product Reviewed", properties: properties)
        LoggerAnalytics.debug("✅ Tracked Product Reviewed event")
    }

    // MARK: - Screen Events

    func screenEventWithoutProperties() {
        analytics?.screen(screenName: "View Controller 1")
        LoggerAnalytics.debug("✅ Tracked screen event without properties")
    }

    func screenEventWithProperties() {
        let properties: [String: Any] = [
            "key1": "value 1",
            "key2": 100,
            "key3": 200.25
        ]
        analytics?.screen(screenName: "View Controller 2", properties: properties)
        LoggerAnalytics.debug("✅ Tracked screen event with properties")
    }
}
