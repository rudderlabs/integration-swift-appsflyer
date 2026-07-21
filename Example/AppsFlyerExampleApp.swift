//
//  AppsFlyerExampleApp.swift
//  AppsFlyerExample
//
//  Created by Vishal Gupta on 26/11/25.
//

import SwiftUI
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

        // Initialize AppsFlyer SDK first (before Analytics).
        // In SDK v7, credentials are supplied via `initialize(devKey:appId:)`;
        // the `appsFlyerDevKey`/`appleAppID` properties are now read-only.
        // Enable debug logging before `initialize(devKey:appId:)` — setting it
        // afterwards is too late for the SDK to pick up and suppresses its logs.
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().initialize(
            devKey: "<YOUR_APPSFLYER_DEV_KEY>",
            appId: "<YOUR_APPLE_APP_ID>"
        )

        // In SDK v7 the SDK no longer manages ATT timing internally. Register a
        // session-ready listener and start the SDK from inside it, collecting
        // ATT consent first so the session carries the resolved status.
        AppsFlyerLib.shared().registerSessionReadyListener {
            requestTrackingPermission {
                AppsFlyerLib.shared().start()
            }
        }
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

    /// Requests ATT authorization and invokes `completion` once the user has
    /// responded, so the caller can start the SDK with a resolved status.
    private func requestTrackingPermission(completion: @escaping () -> Void) {
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
            completion()
        }
    }
}
