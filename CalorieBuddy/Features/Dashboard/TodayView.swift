//
//  TodayView.swift
//  CalorieBuddy
//
//  The Today tab: greeting + streak, day navigation, and the dashboard.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]
    @Query private var streaks: [Streak]
    @State private var showCalendar = false

    private var profile: UserProfile? { profiles.first }
    private var streak: Streak? { streaks.first }

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    dateNav
                    DayDashboard(date: appState.selectedDate, profile: profile)
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.top, Spacing.sm)
                .padding(.bottom, 110)
            }
            .background {
                (profile?.dashboardBackground ?? .default).view.ignoresSafeArea()
            }
            .navigationDestination(for: FoodEntry.self) { entry in
                FoodDetailView(entry: entry)
            }
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { streakPill }
            }
            .sheet(isPresented: $showCalendar) {
                calendarSheet(appState: appState)
            }
        }
    }

    // MARK: Date navigation

    private var dateNav: some View {
        HStack {
            CircleIconButton(systemImage: "chevron.left", size: 36) { shiftDay(-1) }
            Spacer()
            Button {
                showCalendar = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(dateLabel).font(CBFont.headline)
                }
                .foregroundStyle(Theme.ink)
            }
            .buttonStyle(.plain)
            Spacer()
            CircleIconButton(systemImage: "chevron.right", size: 36) { shiftDay(1) }
                .opacity(canGoForward ? 1 : 0.3)
                .disabled(!canGoForward)
        }
    }

    private func calendarSheet(appState: AppState) -> some View {
        @Bindable var appState = appState
        return NavigationStack {
            DatePicker("Select date",
                       selection: $appState.selectedDate,
                       in: ...Calendar.current.startOfDay(for: .now),
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Jump to a day")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showCalendar = false }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }

    private var streakPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill").foregroundStyle(Theme.amber)
            Text("\(streak?.current ?? 0)")
                .font(CBFont.subheadline.weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.surfaceAlt, in: Capsule())
    }

    // MARK: Helpers

    private var canGoForward: Bool {
        Calendar.current.startOfDay(for: appState.selectedDate) < Calendar.current.startOfDay(for: .now)
    }

    private func shiftDay(_ delta: Int) {
        if delta > 0 && !canGoForward { return }
        let cal = Calendar.current
        if let newDate = cal.date(byAdding: .day, value: delta, to: appState.selectedDate) {
            appState.selectedDate = cal.startOfDay(for: newDate)
            Haptics.selection()
        }
    }

    private var dateLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(appState.selectedDate) { return "Today" }
        if cal.isDateInYesterday(appState.selectedDate) { return "Yesterday" }
        return appState.selectedDate.formatted(.dateTime.weekday(.abbreviated).month().day())
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        case 17..<22: "Good evening"
        default: "Hello"
        }
    }
}

#Preview {
    TodayView()
        .environment(AppState())
        .environment(HealthKitService())
        .modelContainer(AppContainer.preview)
}
