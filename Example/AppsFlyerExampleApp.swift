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

    @Environment(\.scenePhase) private var scenePhase

    init() {
        setupAppsFlyer()
        setupAnalytics()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase) {
            if scenePhase == .active {
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
