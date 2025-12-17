//
//  AppsFlyerAdapter.swift
//  integration-swift-appsflyer
//
//  Created by Vishal Gupta on 25/11/25.
//

import Foundation
import AppsFlyerLib

/**
 * Protocol to wrap AppsFlyerLib.
 */
protocol AppsFlyerAdapter {
    var appsFlyerInstance: Any? { get set }
    func setCustomerUserID(_ customerUserID: String?)
    func setUserEmails(_ userEmails: [String], withCryptType type: EmailCryptType)
    func logEvent(_ eventName: String, withValues values: [String: Any])
    func provideAppsFlyerInstance() -> Any
}

// MARK: Actual Implementation
class DefaultAppsFlyerAdapter: AppsFlyerAdapter {
    var appsFlyerInstance: Any?

    private var appsFlyer: AppsFlyerLib? {
        return appsFlyerInstance as? AppsFlyerLib
    }

    func setCustomerUserID(_ customerUserID: String?) {
        appsFlyer?.customerUserID = customerUserID
    }

    func setUserEmails(_ userEmails: [String], withCryptType type: EmailCryptType) {
        appsFlyer?.setUserEmails(userEmails, with: type)
    }

    func logEvent(_ eventName: String, withValues values: [String: Any]) {
        appsFlyer?.logEvent(eventName, withValues: values)
    }

    func provideAppsFlyerInstance() -> Any {
        return AppsFlyerLib.shared()
    }
}
