import Foundation
import AppsFlyerLib
import RudderStackAnalytics

/**
 * AppsFlyer Integration for RudderStack Swift SDK
 */
public class AppsFlyerIntegration: IntegrationPlugin, StandardIntegration {
    
    // MARK: - Adapter
    
    final var appsFlyerAdapter: AppsFlyerAdapter
    
    // MARK: - IntegrationPlugin Properties
    
    /**
     Plugin type for AppsFlyer integration
     */
    public var pluginType: PluginType = .terminal
    
    /**
     Reference to the analytics instance
     */
    public var analytics: Analytics?
    
    /**
     Integration key identifier
     */
    public var key: String = "AppsFlyer"
    
    // MARK: - Private Properties
    
    private var isNewScreenEnabled: Bool = false
    private let trackReservedKeywords: [String] = [
        "query", "price", "product_id", "category", "currency", "products",
        "quantity", "total", "revenue", "order_id", "share_message", "creative", "rating"
    ]
    
    // MARK: - Constants
    
    private struct Constants {
        static let firstPurchase = "first_purchase"
        static let creative = "creative"
    }
    
    // MARK: - Initialization
    
    init(appsFlyerAdapter: AppsFlyerAdapter) {
        self.appsFlyerAdapter = appsFlyerAdapter
    }
    
    public convenience init() {
        self.init(appsFlyerAdapter: DefaultAppsFlyerAdapter())
    }
    
    // MARK: - IntegrationPlugin Methods
    
    /**
     * Creates and initializes the AppsFlyer integration
     */
    public func create(destinationConfig: [String: Any]) throws {
        // Assign AppsFlyer instance if not already assigned
        if appsFlyerAdapter.appsFlyerInstance == nil {
            appsFlyerAdapter.appsFlyerInstance = appsFlyerAdapter.provideAppsFlyerInstance()
        }
        
        // Extract configuration
        isNewScreenEnabled = destinationConfig["useRichEventName"] as? Bool ?? false
        
        LoggerAnalytics.debug("AppsFlyer integration initialized with useRichEventName: \(isNewScreenEnabled)")
    }
    
    /**
     * Returns the AppsFlyer SDK instance
     * Required by IntegrationPlugin protocol
     */
    public func getDestinationInstance() -> Any? {
        return appsFlyerAdapter.appsFlyerInstance
    }
    
    /**
     * Updates the AppsFlyer integration configuration
     */
    public func update(destinationConfig: [String: Any]) throws {
        // Update configuration without re-initialization
        isNewScreenEnabled = destinationConfig["useRichEventName"] as? Bool ?? false
        
        LoggerAnalytics.debug("AppsFlyer integration configuration updated with useRichEventName: \(isNewScreenEnabled)")
    }
    
    // MARK: - Event Methods
    
    /**
     * Handles identify events
     */
    public func identify(payload: IdentifyEvent) {
        // Set customer user ID
        if let userId = payload.userId, !userId.isEmpty {
            appsFlyerAdapter.setCustomerUserID(userId)
            LoggerAnalytics.debug("AppsFlyer: Set customer user ID: \(userId)")
        }
        
        // Handle email with SHA256 encryption
        if let traits = payload.context?["traits"] as? AnyCodable {
            if let traitsDictionary = traits.value as? [String: Any],
               let email = traitsDictionary["email"] as? String, !email.isEmpty {
                appsFlyerAdapter.setUserEmails([email], withCryptType: EmailCryptTypeSHA256)
                LoggerAnalytics.debug("AppsFlyer: Set user email with SHA256 encryption")
            }
        }
    }
    
    /**
     * Handles track events
     */
    public func track(payload: TrackEvent) {
        let eventName = payload.event
        guard !eventName.isEmpty else {
            LoggerAnalytics.debug("AppsFlyer: Event name is empty, dropping track event")
            return
        }
        
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]
        var afEventName = eventName.lowercased()
        var afProperties: [String: Any] = [:]
        
        // Handle ecommerce events with special mapping
        switch eventName {
        case ECommerceEvents.productsSearched:
            afEventName = AFEventSearch
            if let query = properties["query"] as? String {
                afProperties[AFEventParamSearchString] = query
            }
            
        case ECommerceEvents.productViewed:
            afEventName = AFEventContentView
            addProductProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.productListViewed:
            afEventName = AFEventListView
            addProductListViewedProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.productAddedToWishList:
            afEventName = AFEventAddToWishlist
            addProductProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.productAdded:
            afEventName = AFEventAddToCart
            addProductProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.checkoutStarted:
            afEventName = AFEventInitiatedCheckout
            addCheckoutProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.orderCompleted:
            afEventName = AFEventPurchase
            addCheckoutProperties(properties: properties, params: &afProperties)
            
        case Constants.firstPurchase:
            afEventName = Constants.firstPurchase
            addCheckoutProperties(properties: properties, params: &afProperties)
            
        case ECommerceEvents.promotionViewed:
            afEventName = AFEventAdView
            handlePromotionEvent(properties: properties, params: &afProperties)
            
        case ECommerceEvents.promotionClicked:
            afEventName = AFEventAdClick
            handlePromotionEvent(properties: properties, params: &afProperties)
            
        case ECommerceEvents.paymentInfoEntered:
            afEventName = AFEventAddPaymentInfo
            
        case ECommerceEvents.productShared, ECommerceEvents.cartShared:
            afEventName = AFEventShare
            if let shareMessage = properties["share_message"] as? String {
                afProperties[AFEventParamDescription] = shareMessage
            }
            
        case ECommerceEvents.productReviewed:
            afEventName = AFEventRate
            if let productId = properties["product_id"] as? String {
                afProperties[AFEventParamContentId] = productId
            }
            if let rating = properties["rating"] {
                afProperties[AFEventParamRatingValue] = rating
            }
            
        case ECommerceEvents.productRemoved:
            afEventName = "remove_from_cart"
            if let productId = properties["product_id"] as? String {
                afProperties[AFEventParamContentId] = productId
            }
            if let category = properties["category"] as? String {
                afProperties[AFEventParamContentType] = category
            }
            
        default:
            // Convert spaces to underscores for custom events
            afEventName = afEventName.replacingOccurrences(of: " ", with: "_")
        }
        
        // Attach all custom properties (excluding reserved keywords)
        attachAllCustomProperties(afProperties: &afProperties, properties: properties)
        
        // Log the event
        appsFlyerAdapter.logEvent(afEventName, withValues: afProperties)
        LoggerAnalytics.debug("AppsFlyer: Logged event '\(afEventName)' with properties: \(afProperties)")
    }
    
    /**
     * Handles screen events
     */
    public func screen(payload: ScreenEvent) {
        let properties = payload.properties?.dictionary?.rawDictionary ?? [:]
        var screenName: String
        
        if isNewScreenEnabled {
            let eventName = payload.event
            if !eventName.isEmpty {
                screenName = "Viewed \(eventName) Screen"
            } else if let name = properties["name"] as? String, !name.isEmpty {
                screenName = "Viewed \(name) Screen"
            } else {
                screenName = "Viewed Screen"
            }
        } else {
            screenName = "screen"
        }
        
        // Log screen event
        appsFlyerAdapter.logEvent(screenName, withValues: properties)
        LoggerAnalytics.debug("AppsFlyer: Logged screen event '\(screenName)' with properties: \(properties)")
    }
    
    // MARK: - Private Helper Methods
    
    private func addCheckoutProperties(properties: [String: Any], params: inout [String: Any]) {
        // Handle total/price
        if let total = properties["total"] {
            params[AFEventParamPrice] = total
        }
        
        // Handle products array
        if let products = properties["products"] as? [[String: Any]] {
            var productIds: [String] = []
            var productCategories: [String] = []
            var productQuantities: [Any] = []
            
            for product in products {
                if let productId = product["product_id"] as? String,
                   let category = product["category"] as? String,
                   let quantity = product["quantity"] {
                    productIds.append(productId)
                    productCategories.append(category)
                    productQuantities.append(quantity)
                }
            }
            
            if !productIds.isEmpty {
                params[AFEventParamContentId] = productIds
                params[AFEventParamContentType] = productCategories
                params[AFEventParamQuantity] = productQuantities
            }
        }
        
        // Handle currency
        if let currency = properties["currency"] as? String {
            params[AFEventParamCurrency] = currency
        }
        
        // Handle order ID
        if let orderId = properties["order_id"] as? String {
            params[AFEventParamReceiptId] = orderId
            params[AFEventParamOrderId] = orderId
        }
        
        // Handle revenue
        if let revenue = properties["revenue"] {
            params[AFEventParamRevenue] = revenue
        }
    }
    
    private func addProductListViewedProperties(properties: [String: Any], params: inout [String: Any]) {
        // Handle category
        if let category = properties["category"] as? String {
            params[AFEventParamContentType] = category
        }
        
        // Handle products array
        if let products = properties["products"] as? [[String: Any]] {
            var productIds: [String] = []
            
            for product in products {
                if let productId = product["product_id"] as? String {
                    productIds.append(productId)
                }
            }
            
            if !productIds.isEmpty {
                params[AFEventParamContentList] = productIds
            }
        }
    }
    
    private func addProductProperties(properties: [String: Any], params: inout [String: Any]) {
        // Handle price
        if let price = properties["price"] {
            params[AFEventParamPrice] = price
        }
        
        // Handle product ID
        if let productId = properties["product_id"] as? String {
            params[AFEventParamContentId] = productId
        }
        
        // Handle category
        if let category = properties["category"] as? String {
            params[AFEventParamContentType] = category
        }
        
        // Handle currency
        if let currency = properties["currency"] as? String {
            params[AFEventParamCurrency] = currency
        }
        
        // Handle quantity
        if let quantity = properties["quantity"] {
            params[AFEventParamQuantity] = quantity
        }
    }
    
    private func handlePromotionEvent(properties: [String: Any], params: inout [String: Any]) {
        // Handle creative
        if let creative = properties[Constants.creative] {
            params["af_adrev_ad_type"] = creative
            params[kAppsFlyerAdRevenueAdType] = creative
        }
        
        // Handle currency
        if let currency = properties["currency"] as? String {
            params[AFEventParamCurrency] = currency
        }
    }
    
    private func attachAllCustomProperties(afProperties: inout [String: Any], properties: [String: Any]) {
        guard !properties.isEmpty else { return }
        
        for (key, value) in properties {
            // Skip reserved keywords and empty keys
            guard !trackReservedKeywords.contains(key), !key.isEmpty else { continue }
            
            afProperties[key] = value
        }
    }
}
