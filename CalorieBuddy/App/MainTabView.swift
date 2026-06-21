//
//  MainTabView.swift
//  CalorieBuddy
//
//  The main app shell: an iOS 26 Liquid Glass tab bar with a center scan
//  action, hosting the Today, Diary, Stats, and Settings tabs.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreService.self) private var store

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            Tab("Today", systemImage: "house.fill", value: AppState.Tab.today) {
                TodayView()
            }
            Tab("Diary", systemImage: "book.closed.fill", value: AppState.Tab.diary) {
                DiaryView()
            }
            Tab("Stats", systemImage: "chart.bar.xaxis", value: AppState.Tab.stats) {
                StatsView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppState.Tab.settings) {
                SettingsView()
            }
        }
        .overlay(alignment: .bottom) {
            ScanButton { appState.presentScanner() }
                .padding(.bottom, 64)
                .allowsHitTesting(true)
        }
        .sheet(isPresented: $appState.isShowingScanner) {
            ScanFlowView()
        }
        .sheet(isPresented: $appState.isShowingPaywall) {
            PaywallView()
        }
        .overlay {
            if let days = appState.celebrationDay {
                StreakCelebrationView(days: days) { appState.celebrationDay = nil }
                    .zIndex(10)
            }
        }
        .animation(.smooth(duration: 0.3), value: appState.celebrationDay)
        .task {
            // Final onboarding step: surface the paywall once the shell is up.
            guard appState.pendingPostOnboardingPaywall else { return }
            appState.pendingPostOnboardingPaywall = false
            try? await Task.sleep(for: .seconds(0.6))
            if !store.isPro { appState.presentPaywall(context: "onboarding") }
        }
    }
}

/// Raised circular scan action that floats above the tab bar.
private struct ScanButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Theme.brandGradient, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                .cbShadow(.floating)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scan a meal")
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(StoreService())
        .modelContainer(AppContainer.preview)
}
