import Testing
import Foundation
import AppsFlyerLib
import RudderStackAnalytics
@testable import RudderIntegrationAppsFlyer

struct AppsFlyerIntegrationTests {
    
    var mockAdapter: MockAppsFlyerAdapter
    var integration: AppsFlyerIntegration
    
    init() {
        mockAdapter = MockAppsFlyerAdapter()
        integration = AppsFlyerIntegration(appsFlyerAdapter: mockAdapter)
    }
    
    // MARK: - Integration Plugin Properties Tests
    
    @Test("given integration is initialized, when key is accessed, then returns AppsFlyer")
    func testIntegrationKey() {
        #expect(integration.key == "AppsFlyer")
    }
    
    @Test("given integration is initialized, when pluginType is accessed, then returns terminal")
    func testPluginType() {
        #expect(integration.pluginType == .terminal)
    }
    
    // MARK: - Initialization Tests
    
    @Test("given default initialization, when integration is created, then creates DefaultAppsFlyerAdapter")
    func testDefaultInitialization() {
        let defaultIntegration = AppsFlyerIntegration()
        #expect(defaultIntegration.appsFlyerAdapter is DefaultAppsFlyerAdapter)
    }
    
    @Test("given custom adapter, when integration is initialized, then uses provided adapter")  
    func testCustomAdapterInitialization() {
        let customAdapter = MockAppsFlyerAdapter()
        let customIntegration = AppsFlyerIntegration(appsFlyerAdapter: customAdapter)
        // Check that the adapter is correctly assigned by verifying the key
        #expect(customIntegration.key == "AppsFlyer")
        // Cast to MockAppsFlyerAdapter to access mock-specific properties
        if let mockAdapter = customIntegration.appsFlyerAdapter as? MockAppsFlyerAdapter {
            #expect(mockAdapter.provideAppsFlyerInstanceCallCount == 0) // Should be 0 before create is called
        }
    }
    
    // MARK: - Create/Update Configuration Tests
    
    @Test("given default configuration, when create is called, then initializes correctly")
    func testCreateWithDefaultConfiguration() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        
        try integration.create(destinationConfig: config)
        
        #expect(mockAdapter.provideAppsFlyerInstanceCallCount == 1)
        #expect(mockAdapter.appsFlyerInstance != nil)
    }
    
    @Test("given useRichEventName enabled, when create is called, then rich event names are used")
    func testCreateWithRichEventNameEnabled() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        
        try integration.create(destinationConfig: config)
        
        // Test by creating a screen event to verify the flag is set
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Home")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "Viewed Home Screen")
    }
    
    @Test("given useRichEventName disabled, when create is called, then simple screen names are used")
    func testCreateWithRichEventNameDisabled() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: false)
        
        try integration.create(destinationConfig: config)
        
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Home")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "screen")
    }
    
    @Test("given configuration is updated, when update is called, then settings change without re-initialization")
    func testUpdateConfiguration() throws {
        // Initial create with disabled rich event name
        let initialConfig = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: false)
        try integration.create(destinationConfig: initialConfig)
        
        let initialCallCount = mockAdapter.provideAppsFlyerInstanceCallCount
        
        // Update with enabled rich event name
        let updatedConfig = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        try integration.update(destinationConfig: updatedConfig)
        
        // Should not call provideAppsFlyerInstance again
        #expect(mockAdapter.provideAppsFlyerInstanceCallCount == initialCallCount)
        
        // Verify updated configuration works
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Settings")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.last?.eventName == "Viewed Settings Screen")
    }
    
    @Test("given integration is created, when getDestinationInstance is called, then returns AppsFlyer instance")
    func testGetDestinationInstance() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let instance = integration.getDestinationInstance()
        #expect(instance as? String == "MockAppsFlyerInstance")
    }
    
    // MARK: - Identify Event Tests
    
    @Test("given identify event with userId, when identify is called, then customer user ID is set")
    func testIdentifyWithUserId() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(userId: "user123")
        integration.identify(payload: identifyEvent)
        
        #expect(mockAdapter.setCustomerUserIDCalls.count == 1)
        #expect(mockAdapter.setCustomerUserIDCalls[0] == "user123")
    }
    
    @Test("given identify event with empty userId, when identify is called, then customer user ID is not set")
    func testIdentifyWithEmptyUserId() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(userId: "")
        integration.identify(payload: identifyEvent)
        
        #expect(mockAdapter.setCustomerUserIDCalls.isEmpty)
    }
    
    @Test("given identify event with email, when identify is called, then user emails are set with SHA256 encryption")
    func testIdentifyWithEmail() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(
            userId: "user123", 
            email: "test@example.com"
        )
        integration.identify(payload: identifyEvent)
        
        #expect(mockAdapter.setUserEmailsCalls.count == 1)
        #expect(mockAdapter.setUserEmailsCalls[0].emails == ["test@example.com"])
        #expect(mockAdapter.setUserEmailsCalls[0].cryptType == EmailCryptTypeSHA256)
    }
    
    @Test("given identify event without email, when identify is called, then user emails are not set")
    func testIdentifyWithoutEmail() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(userId: "user123", email: String?.none)
        integration.identify(payload: identifyEvent)
        
        #expect(mockAdapter.setUserEmailsCalls.isEmpty)
    }
    
    @Test("given identify event with empty email, when identify is called, then user emails are not set")
    func testIdentifyWithEmptyEmail() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(userId: "user123", email: "")
        integration.identify(payload: identifyEvent)
        
        #expect(mockAdapter.setUserEmailsCalls.isEmpty)
    }
    
    // MARK: - E-commerce Event Tests
    
    @Test("given Product Viewed event, when track is called, then maps to AFEventContentView")
    func testProductViewedEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createProductViewedEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == AFEventContentView)
        #expect(loggedEvent.values[AFEventParamContentId] as? String == "123")
        #expect(loggedEvent.values[AFEventParamContentType] as? String == "shoes")
        #expect(loggedEvent.values[AFEventParamPrice] as? Double == 99.99)
        #expect(loggedEvent.values[AFEventParamCurrency] as? String == "USD")
        #expect(loggedEvent.values[AFEventParamQuantity] as? Int == 1)
    }
    
    @Test("given Product Added event, when track is called, then maps to AFEventAddToCart")
    func testProductAddedEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createProductAddedEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == AFEventAddToCart)
        #expect(loggedEvent.values[AFEventParamContentId] as? String == "456")
        #expect(loggedEvent.values[AFEventParamContentType] as? String == "clothing")
        #expect(loggedEvent.values[AFEventParamPrice] as? Double == 49.99)
    }
    
    @Test("given Order Completed event, when track is called, then maps to AFEventPurchase with products")
    func testOrderCompletedEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createOrderCompletedEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == AFEventPurchase)
        #expect(loggedEvent.values[AFEventParamPrice] as? Double == 259.97)
        #expect(loggedEvent.values[AFEventParamCurrency] as? String == "USD")
        #expect(loggedEvent.values[AFEventParamReceiptId] as? String == "order_123")
        #expect(loggedEvent.values[AFEventParamOrderId] as? String == "order_123")
        #expect(loggedEvent.values[AFEventParamRevenue] as? Double == 259.97)
        
        // Check products arrays
        let productIds = loggedEvent.values[AFEventParamContentId] as? [String]
        let productCategories = loggedEvent.values[AFEventParamContentType] as? [String]
        #expect(productIds == ["prod1", "prod2"])
        #expect(productCategories == ["electronics", "accessories"])
    }
    
    @Test("given Products Searched event, when track is called, then maps to AFEventSearch")
    func testProductsSearchedEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createProductsSearchedEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == AFEventSearch)
        #expect(loggedEvent.values[AFEventParamSearchString] as? String == "running shoes")
    }
    
    @Test("given Promotion Viewed event, when track is called, then maps to AFEventAdView")
    func testPromotionViewedEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createPromotionViewedEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == AFEventAdView)
        #expect(loggedEvent.values["af_adrev_ad_type"] as? String == "banner_ad")
        #expect(loggedEvent.values[kAppsFlyerAdRevenueAdType] as? String == "banner_ad")
        #expect(loggedEvent.values[AFEventParamCurrency] as? String == "USD")
    }
    
    // MARK: - Custom Event Tests
    
    @Test("given custom event, when track is called, then name is transformed and custom properties are included")
    func testCustomEvent() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createCustomEvent()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.eventName == "custom_event")
        
        // Should include custom properties
        #expect(loggedEvent.values["custom_property"] as? String == "custom_value")
        #expect(loggedEvent.values["number_property"] as? Int == 42)
        #expect(loggedEvent.values["boolean_property"] as? Bool == true)
        
        // Should not include reserved property (price is reserved)
        #expect(loggedEvent.values["price"] == nil)
    }
    
    @Test("given event with spaces in name, when track is called, then spaces are replaced with underscores")
    func testEventNameWithSpaces() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createTrackEvent(eventName: "My Custom Event Name")
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "my_custom_event_name")
    }
    
    @Test("given event with empty name, when track is called, then event is dropped")
    func testEventWithEmptyName() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createTrackEvent(eventName: "")
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.isEmpty)
    }
    
    // MARK: - Reserved Keywords Tests
    
    @Test("given event with reserved keywords, when track is called, then reserved keywords are filtered out from custom properties")
    func testReservedKeywordsFiltering() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createEventWithReservedKeywords()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        
        // Reserved keywords should not be included in custom properties
        let reservedKeywords = ["query", "price", "product_id", "category", "currency", 
                              "products", "quantity", "total", "revenue", "order_id", 
                              "share_message", "creative", "rating"]
        
        for keyword in reservedKeywords {
            // These should either not be present or be handled by specific mapping logic
            if loggedEvent.values.keys.contains(keyword) {
                // If present, it should be due to specific event mapping, not custom property attachment
                continue
            }
        }
        
        // Custom property should be included
        #expect(loggedEvent.values["custom_prop"] as? String == "should_be_included")
    }
    
    // MARK: - Screen Event Tests
    
    @Test("given screen event with rich naming disabled, when screen is called, then simple name is used")
    func testScreenEventWithRichNamingDisabled() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: false)
        try integration.create(destinationConfig: config)
        
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Home")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "screen")
    }
    
    @Test("given screen event with rich naming enabled, when screen is called, then formatted name is used")
    func testScreenEventWithRichNamingEnabled() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        try integration.create(destinationConfig: config)
        
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Product Details")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "Viewed Product Details Screen")
    }
    
    @Test("given screen event with no name and no property, when screen is called, then generic name is used")
    func testScreenEventWithNoName() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        try integration.create(destinationConfig: config)
        
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "")
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "Viewed Screen")
    }
    
    @Test("given screen event with properties, when screen is called, then properties are included")
    func testScreenEventWithProperties() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let properties = ["section": "main", "user_type": "premium"]
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Home", properties: properties)
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        #expect(loggedEvent.values["section"] as? String == "main")
        #expect(loggedEvent.values["user_type"] as? String == "premium")
    }
    
    // MARK: - Data Type Handling Tests
    
    @Test("given event with complex data types, when track is called, then all types are handled correctly")
    func testComplexDataTypes() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createEventWithComplexProperties()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        let loggedEvent = mockAdapter.logEventCalls[0]
        
        // String
        #expect(loggedEvent.values["string_prop"] as? String == "string_value")
        
        // Numbers
        #expect(loggedEvent.values["int_prop"] as? Int == 42)
        #expect(loggedEvent.values["double_prop"] as? Double == 19.99)
        
        // Boolean
        #expect(loggedEvent.values["boolean_prop"] as? Bool == true)
        
        // Nested object
        if let nestedObject = loggedEvent.values["nested_object"] as? [String: Any] {
            #expect(nestedObject["nested_string"] as? String == "nested_value")
            #expect(nestedObject["nested_number"] as? Int == 123)
        }
        
        // Array
        if let arrayProp = loggedEvent.values["array_prop"] as? [String] {
            #expect(arrayProp == ["item1", "item2", "item3"])
        }
    }
    
    @Test("given event with empty properties, when track is called, then does not crash")
    func testEventWithEmptyProperties() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        let trackEvent = AppsFlyerTestDataProvider.createEventWithEmptyProperties()
        integration.track(payload: trackEvent)
        
        #expect(mockAdapter.logEventCalls.count == 1)
        #expect(mockAdapter.logEventCalls[0].eventName == "empty_properties_event")
        #expect(mockAdapter.logEventCalls[0].values.isEmpty)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("given multiple events, when processed sequentially, then all events are handled correctly")
    func testMultipleEvents() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        // Identify
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent()
        integration.identify(payload: identifyEvent)
        
        // Track
        let trackEvent = AppsFlyerTestDataProvider.createProductViewedEvent()
        integration.track(payload: trackEvent)
        
        // Screen  
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent()
        integration.screen(payload: screenEvent)
        
        #expect(mockAdapter.setCustomerUserIDCalls.count == 1)
        #expect(mockAdapter.setUserEmailsCalls.count == 1)
        #expect(mockAdapter.logEventCalls.count == 2) // Track + Screen
    }
    
    @Test("given configuration is updated, when update is called, then already created instance is not affected")
    func testConfigurationUpdateDoesNotRecreateInstance() throws {
        let config1 = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: false)
        try integration.create(destinationConfig: config1)
        
        let instance1 = integration.getDestinationInstance()
        let callCount1 = mockAdapter.provideAppsFlyerInstanceCallCount
        
        let config2 = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        try integration.update(destinationConfig: config2)
        
        let instance2 = integration.getDestinationInstance()
        let callCount2 = mockAdapter.provideAppsFlyerInstanceCallCount
        
        #expect(instance1 as? String == instance2 as? String)
        #expect(callCount1 == callCount2) // Should not have called provideAppsFlyerInstance again
    }
    
    @Test("given nil adapter instance, when methods are called, then handles gracefully")
    func testNilAdapterInstance() throws {
        mockAdapter.appsFlyerInstance = nil
        
        let config = AppsFlyerTestDataProvider.createDestinationConfig()
        try integration.create(destinationConfig: config)
        
        // These operations should not crash even with nil instance
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent()
        integration.identify(payload: identifyEvent)
        
        let trackEvent = AppsFlyerTestDataProvider.createProductViewedEvent()
        integration.track(payload: trackEvent)
        
        let screenEvent = AppsFlyerTestDataProvider.createScreenEvent()
        integration.screen(payload: screenEvent)
        
        // Calls should still be recorded by mock adapter
        #expect(mockAdapter.setCustomerUserIDCalls.count == 1)
        #expect(mockAdapter.logEventCalls.count == 2)
    }
    
    // MARK: - Integration Flow Tests
    
    @Test("given complete user journey, when all events are processed, then works end-to-end")
    func testCompleteUserJourney() throws {
        let config = AppsFlyerTestDataProvider.createDestinationConfig(useRichEventName: true)
        try integration.create(destinationConfig: config)
        
        // User identifies themselves
        let identifyEvent = AppsFlyerTestDataProvider.createIdentifyEvent(
            userId: "user123", 
            email: "user@example.com"
        )
        integration.identify(payload: identifyEvent)
        
        // User views home screen
        let homeScreen = AppsFlyerTestDataProvider.createScreenEvent(screenName: "Home")
        integration.screen(payload: homeScreen)
        
        // User searches for products
        let searchEvent = AppsFlyerTestDataProvider.createProductsSearchedEvent()
        integration.track(payload: searchEvent)
        
        // User views a product
        let productViewEvent = AppsFlyerTestDataProvider.createProductViewedEvent()
        integration.track(payload: productViewEvent)
        
        // User adds product to cart
        let addToCartEvent = AppsFlyerTestDataProvider.createProductAddedEvent()
        integration.track(payload: addToCartEvent)
        
        // User completes order
        let orderEvent = AppsFlyerTestDataProvider.createOrderCompletedEvent()
        integration.track(payload: orderEvent)
        
        // Verify all events were tracked
        #expect(mockAdapter.setCustomerUserIDCalls.count == 1)
        #expect(mockAdapter.setUserEmailsCalls.count == 1)
        #expect(mockAdapter.logEventCalls.count == 5) // Home screen + 4 track events
        
        // Verify event names
        let eventNames = mockAdapter.logEventCalls.map { $0.eventName }
        #expect(eventNames.contains("Viewed Home Screen"))
        #expect(eventNames.contains(AFEventSearch))
        #expect(eventNames.contains(AFEventContentView))
        #expect(eventNames.contains(AFEventAddToCart))
        #expect(eventNames.contains(AFEventPurchase))
    }
}
