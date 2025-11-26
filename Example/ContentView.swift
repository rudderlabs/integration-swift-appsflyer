//
//  ContentView.swift
//  AppsFlyerExample
//
//  Created by Vishal Gupta on 26/11/25.
//

import SwiftUI
import RudderStackAnalytics

struct ContentView: View {
    private var analyticsManager = AnalyticsManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // User Identity Section
                    userIdentitySection

                    // Custom Events Section
                    customEventsSection

                    // Product Search Section
                    productSearchSection

                    // Product List Events Section
                    productListEventsSection

                    // Single Product Events Section
                    singleProductEventsSection

                    // Checkout Events Section
                    checkoutEventsSection

                    // Promotion Events Section
                    promotionEventsSection

                    // Payment and Sharing Events Section
                    paymentAndSharingEventsSection

                    // Screen Events Section
                    screenEventsSection
                }
                .padding()
            }
            .navigationTitle("AppsFlyer Example")
        }
    }
}

extension ContentView {
    
    var userIdentitySection: some View {
        VStack(spacing: 12) {
            Text("User Identity")
                .font(.headline)

            Button("Identify User (Simple)") {
                analyticsManager.identifyUserSimple()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Identify User (With Traits)") {
                analyticsManager.identifyUser()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Alias User") {
                analyticsManager.aliasUser()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    var customEventsSection: some View {
        VStack(spacing: 12) {
            Text("Custom Events")
                .font(.headline)

            Button("Custom Track Event") {
                analyticsManager.customTrackEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    var productSearchSection: some View {
        VStack(spacing: 12) {
            Text("Search Events")
                .font(.headline)

            Button("Products Searched") {
                analyticsManager.productsSearchedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    var productListEventsSection: some View {
        VStack(spacing: 12) {
            Text("Product List Events")
                .font(.headline)

            Button("Product List Viewed") {
                analyticsManager.productListViewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    var singleProductEventsSection: some View {
        VStack(spacing: 12) {
            Text("Single Product Events")
                .font(.headline)

            Button("Product Viewed") {
                analyticsManager.productViewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Product Added to Wishlist") {
                analyticsManager.productAddedToWishlistEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Product Added") {
                analyticsManager.productAddedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Product Removed") {
                analyticsManager.productRemovedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }

    var checkoutEventsSection: some View {
        VStack(spacing: 12) {
            Text("Checkout Events")
                .font(.headline)

            Button("Checkout Started") {
                analyticsManager.checkoutStartedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Order Completed") {
                analyticsManager.orderCompletedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }

    var promotionEventsSection: some View {
        VStack(spacing: 12) {
            Text("Promotion Events")
                .font(.headline)

            Button("Promotion Viewed") {
                analyticsManager.promotionViewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Promotion Clicked") {
                analyticsManager.promotionClickedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.teal.opacity(0.1))
        .cornerRadius(10)
    }

    var paymentAndSharingEventsSection: some View {
        VStack(spacing: 12) {
            Text("Payment & Sharing Events")
                .font(.headline)

            Button("Payment Info Entered") {
                analyticsManager.paymentInfoEnteredEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Product Shared") {
                analyticsManager.productSharedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Cart Shared") {
                analyticsManager.cartSharedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Product Reviewed") {
                analyticsManager.productReviewedEvent()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .cornerRadius(10)
    }

    var screenEventsSection: some View {
        VStack(spacing: 12) {
            Text("Screen Events")
                .font(.headline)

            Button("Screen (No Properties)") {
                analyticsManager.screenEventWithoutProperties()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Screen (With Properties)") {
                analyticsManager.screenEventWithProperties()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(10)
    }

}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}
