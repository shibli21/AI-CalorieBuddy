//
//  CalorieBuddyApp.swift
//  CalorieBuddy
//
//  App entry point: builds the SwiftData container and injects app state + services.
//

import SwiftUI
import SwiftData

@main
struct CalorieBuddyApp: App {
    @State private var appState = AppState()
    @State private var ai = AIService()
    @State private var store = StoreService()
    @State private var health = HealthKitService()
    @State private var notifications = NotificationService()

    private let container = AppContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(ai)
                .environment(store)
                .environment(health)
                .environment(notifications)
                .tint(Theme.accent)
                .preferredColorScheme(appState.preferredColorScheme)
                .task {
                    await store.loadProducts()
                    await store.refreshEntitlements()
                }
        }
        .modelContainer(container)
    }
}
