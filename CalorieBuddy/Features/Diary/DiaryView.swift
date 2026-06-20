//
//  DiaryView.swift
//  CalorieBuddy
//
//  The Diary tab: per-day food log with quick add and recents.
//

import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]
    @State private var showManual = false

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    DayNavBar(date: $appState.selectedDate)
                    DiaryDayContent(date: appState.selectedDate,
                                    profile: profiles.first,
                                    onAddManual: { showManual = true })
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.top, Spacing.sm)
                .padding(.bottom, 110)
            }
            .background(Theme.background)
            .navigationTitle("Diary")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: FoodEntry.self) { entry in
                FoodDetailView(entry: entry)
            }
            .sheet(isPresented: $showManual) {
                ManualFoodEntryView(date: appState.selectedDate)
            }
        }
    }
}

#Preview {
    DiaryView()
        .environment(AppState())
        .environment(HealthKitService())
        .modelContainer(AppContainer.preview)
}
