//
//  ObjCAppsFlyerIntegration.swift
//  RudderIntegrationAppsFlyer
//
//  Created by RudderStack on 11/01/26.
//

import Foundation
import RudderStackAnalytics

// MARK: - ObjCAppsFlyerIntegration
/**
 An Objective-C compatible wrapper for the AppsFlyer Integration.

 This class provides an Objective-C interface to the AppsFlyer integration,
 allowing Objective-C apps to use the AppsFlyer device mode integration with RudderStack.

 ## Usage in Objective-C:
 ```objc
 RSSConfigurationBuilder *builder = [[RSSConfigurationBuilder alloc] initWithWriteKey:@"<WriteKey>"
                                                          dataPlaneUrl:@"<DataPlaneUrl>"];
 RSSAnalytics *analytics = [[RSSAnalytics alloc] initWithConfiguration:[builder build]];

 RSSAppsFlyerIntegration *appsFlyerIntegration = [[RSSAppsFlyerIntegration alloc] init];
 [analytics addPlugin:appsFlyerIntegration];
 ```
 */
@objc(RSSAppsFlyerIntegration)
public class ObjCAppsFlyerIntegration: NSObject, ObjCIntegrationPlugin, ObjCStandardIntegration {

    // MARK: - ObjCPlugin Properties

    public var pluginType: PluginType {
        get { appsFlyerIntegration.pluginType }
        set { appsFlyerIntegration.pluginType = newValue }
    }

    // MARK: - ObjCIntegrationPlugin Properties

    public var key: String {
        get { appsFlyerIntegration.key }
        set { appsFlyerIntegration.key = newValue }
    }

    // MARK: - Private Properties

    private let appsFlyerIntegration: AppsFlyerIntegration

    // MARK: - Initializers

    /**
     Initializes a new AppsFlyer integration instance.

     Use this initializer to create an AppsFlyer integration that can be added to the analytics client.
     */
    @objc
    public override init() {
        self.appsFlyerIntegration = AppsFlyerIntegration()
        super.init()
    }

    // MARK: - ObjCIntegrationPlugin Methods

    /**
     Returns the AppsFlyer SDK instance.

     - Returns: The AppsFlyer SDK instance, or nil if not initialized.
     */
    @objc
    public func getDestinationInstance() -> Any? {
        return appsFlyerIntegration.getDestinationInstance()
    }

    /**
     Creates and configures the AppsFlyer SDK with the provided destination configuration.

     - Parameters:
        - destinationConfig: Configuration dictionary from RudderStack dashboard.
        - errorPointer: A pointer to an NSError that will be set if initialization fails.
     - Returns: `true` if initialization succeeded, `false` otherwise.
     */
    @objc
    public func createWithDestinationConfig(_ destinationConfig: [String: Any], error errorPointer: NSErrorPointer) -> Bool {
        do {
            try appsFlyerIntegration.create(destinationConfig: destinationConfig)
            return true
        } catch let err as NSError {
            errorPointer?.pointee = err
            return false
        } catch {
            errorPointer?.pointee = NSError(
                domain: "com.rudderstack.AppsFlyerIntegration",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
            )
            return false
        }
    }

    /**
     Updates the AppsFlyer SDK configuration with the provided destination configuration.

     - Parameters:
        - destinationConfig: Configuration dictionary from RudderStack dashboard.
        - errorPointer: A pointer to an NSError that will be set if update fails.
     - Returns: `true` if update succeeded, `false` otherwise.
     */
    @objc
    public func updateWithDestinationConfig(_ destinationConfig: [String: Any], error errorPointer: NSErrorPointer) -> Bool {
        do {
            try appsFlyerIntegration.update(destinationConfig: destinationConfig)
            return true
        } catch let err as NSError {
            errorPointer?.pointee = err
            return false
        } catch {
            errorPointer?.pointee = NSError(
                domain: "com.rudderstack.AppsFlyerIntegration",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
            )
            return false
        }
    }

    // MARK: - ObjCEventPlugin Methods

    /**
     Processes a track event and forwards it to the underlying AppsFlyer integration.

     - Parameter payload: The ObjC track event payload.
     */
    @objc
    public func track(_ payload: ObjCTrackEvent) {
        var trackEvent = TrackEvent(
            event: payload.eventName,
            properties: payload.properties,
            options: payload.options
        )
        trackEvent.anonymousId = payload.anonymousId
        trackEvent.userId = payload.userId

        appsFlyerIntegration.track(payload: trackEvent)
    }

    /**
     Processes an identify event and forwards it to the underlying AppsFlyer integration.

     - Parameter payload: The ObjC identify event payload.
     */
    @objc
    public func identify(_ payload: ObjCIdentifyEvent) {
        var identifyEvent = IdentifyEvent(options: payload.options)
        identifyEvent.anonymousId = payload.anonymousId
        identifyEvent.userId = payload.userId
        if let context = payload.context {
            identifyEvent.context = context.mapValues { AnyCodable($0) }
        }

        appsFlyerIntegration.identify(payload: identifyEvent)
    }

    /**
     Processes a screen event and forwards it to the underlying AppsFlyer integration.

     - Parameter payload: The ObjC screen event payload.
     */
    @objc
    public func screen(_ payload: ObjCScreenEvent) {
        var screenEvent = ScreenEvent(
            screenName: payload.screenName,
            category: payload.category,
            properties: payload.properties,
            options: payload.options
        )
        screenEvent.anonymousId = payload.anonymousId
        screenEvent.userId = payload.userId

        appsFlyerIntegration.screen(payload: screenEvent)
    }
}
