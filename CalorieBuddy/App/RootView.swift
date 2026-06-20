//
//  RootView.swift
//  CalorieBuddy
//
//  Gate between onboarding and the main app, driven by the persisted profile.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }
    private var isOnboarded: Bool { profile?.onboardingCompleted ?? false }

    var body: some View {
        ZStack {
            if isOnboarded {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingFlow()
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.4), value: isOnboarded)
    }
}

#Preview("Onboarded") {
    RootView()
        .environment(AppState())
        .modelContainer(AppContainer.preview)
}
