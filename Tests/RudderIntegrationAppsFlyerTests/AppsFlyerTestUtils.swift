//
//  AppsFlyerTestUtils.swift
//  integration-swift-appsflyer
//
//  Created by Vishal Gupta on 25/11/25.
//

import Foundation
import AppsFlyerLib
import RudderStackAnalytics
@testable import RudderIntegrationAppsFlyer

/**
 * Mock implementation for AppsFlyerAdapter for testing purposes
 */
class MockAppsFlyerAdapter: AppsFlyerAdapter {

    var appsFlyerInstance: Any?

    // Capture method calls for verification
    var setCustomerUserIDCalls: [String?] = []
    var setUserEmailsCalls: [(emails: [String], cryptType: EmailCryptType)] = []
    var logEventCalls: [(eventName: String, values: [String: Any])] = []
    var provideAppsFlyerInstanceCallCount: Int = 0

    func setCustomerUserID(_ customerUserID: String?) {
        setCustomerUserIDCalls.append(customerUserID)
    }

    func setUserEmails(_ userEmails: [String], withCryptType type: EmailCryptType) {
        setUserEmailsCalls.append((emails: userEmails, cryptType: type))
    }

    func logEvent(_ eventName: String, withValues values: [String: Any]) {
        logEventCalls.append((eventName: eventName, values: values))
    }

    func provideAppsFlyerInstance() -> Any {
        provideAppsFlyerInstanceCallCount += 1
        return "MockAppsFlyerInstance"
    }
}

/**
 * Test data helper to create various event payloads for testing
 */
struct AppsFlyerTestDataProvider {

    // MARK: - Identify Event Data

    static func createIdentifyEvent(userId: String = "test_user_123", email: String? = "test@example.com") -> IdentifyEvent {
        var event = IdentifyEvent()
        event.userId = userId

        if let email = email {
            let traits = AnyCodable(["email": email])
            event.context = ["traits": traits]
        }

        return event
    }

    // MARK: - Track Event Data

    static func createTrackEvent(
        eventName: String,
        properties: [String: Any] = [:]
    ) -> TrackEvent {
        let event = TrackEvent(event: eventName, properties: properties)
        return event
    }

    // E-commerce events
    static func createProductViewedEvent() -> TrackEvent {
        let properties: [String: Any] = [
            "product_id": "123",
            "category": "shoes",
            "price": 99.99,
            "currency": "USD",
            "quantity": 1
        ]

        return createTrackEvent(eventName: "Product Viewed", properties: properties)
    }

    static func createProductAddedEvent() -> TrackEvent {
        let properties: [String: Any] = [
            "product_id": "456",
            "category": "clothing",
            "price": 49.99,
            "currency": "USD",
            "quantity": 2
        ]

        return createTrackEvent(eventName: "Product Added", properties: properties)
    }

    static func createOrderCompletedEvent() -> TrackEvent {
        let products = [
            [
                "product_id": "prod1",
                "category": "electronics",
                "quantity": 1,
                "price": 199.99
            ],
            [
                "product_id": "prod2",
                "category": "accessories",
                "quantity": 2,
                "price": 29.99
            ]
        ]

        let properties: [String: Any] = [
            "order_id": "order_123",
            "total": 259.97,
            "revenue": 259.97,
            "currency": "USD",
            "products": products
        ]

        return createTrackEvent(eventName: "Order Completed", properties: properties)
    }

    static func createProductsSearchedEvent() -> TrackEvent {
        let properties = [
            "query": "running shoes"
        ]

        return createTrackEvent(eventName: "Products Searched", properties: properties)
    }

    static func createPromotionViewedEvent() -> TrackEvent {
        let properties: [String: Any] = [
            "creative": "banner_ad",
            "currency": "USD"
        ]

        return createTrackEvent(eventName: "Promotion Viewed", properties: properties)
    }

    static func createCustomEvent() -> TrackEvent {
        let properties: [String: Any] = [
            "custom_property": "custom_value",
            "number_property": 42,
            "boolean_property": true,
            "price": 99.99 // This should be filtered out as it's reserved
        ]

        return createTrackEvent(eventName: "Custom Event", properties: properties)
    }

    // MARK: - Screen Event Data

    static func createScreenEvent(
        screenName: String = "Home",
        properties: [String: Any] = [:]
    ) -> ScreenEvent {
        let event = ScreenEvent(screenName: screenName, properties: properties)
        return event
    }

    // MARK: - Destination Config Data

    static func createDestinationConfig(useRichEventName: Bool = false) -> [String: Any] {
        return [
            "useRichEventName": useRichEventName,
            "apiKey": "test_api_key"
        ]
    }

    // MARK: - Complex Data Types

    static func createEventWithComplexProperties() -> TrackEvent {
        let nestedObject: [String: Any] = [
            "nested_string": "nested_value",
            "nested_number": 123
        ]

        let arrayProperty = ["item1", "item2", "item3"]

        let properties: [String: Any] = [
            "string_prop": "string_value",
            "int_prop": 42,
            "double_prop": 19.99,
            "boolean_prop": true,
            "null_prop": NSNull(),
            "nested_object": nestedObject,
            "array_prop": arrayProperty
        ]

        return createTrackEvent(eventName: "Complex Event", properties: properties)
    }

    // MARK: - Edge Cases

    static func createEventWithEmptyProperties() -> TrackEvent {
        return createTrackEvent(eventName: "Empty Properties Event", properties: [:])
    }

    static func createEventWithReservedKeywords() -> TrackEvent {
        let properties: [String: Any] = [
            "query": "search_term",         // reserved
            "price": 99.99,                 // reserved
            "product_id": "prod123",        // reserved
            "category": "electronics",      // reserved
            "currency": "USD",              // reserved
            "products": [],                 // reserved
            "quantity": 1,                  // reserved
            "total": 99.99,                 // reserved
            "revenue": 99.99,               // reserved
            "order_id": "order123",         // reserved
            "share_message": "Check this out!", // reserved
            "creative": "banner",           // reserved
            "rating": 5,                    // reserved
            "custom_prop": "should_be_included" // not reserved
        ]

        return createTrackEvent(eventName: "Reserved Keywords Event", properties: properties)
    }
}
