//
//  DayDashboard.swift
//  CalorieBuddy
//
//  The date-scoped dashboard body: calorie hero, macros, stat cards, and the
//  per-meal log. Queries are built from the date so they refresh when the user
//  navigates between days.
//

import SwiftUI
import SwiftData

struct DayDashboard: View {
    let date: Date
    let profile: UserProfile?

    @Environment(\.modelContext) private var context
    @Environment(HealthKitService.self) private var health
    @Environment(AppState.self) private var appState

    @Query private var entries: [FoodEntry]
    @Query private var waters: [WaterLog]
    @Query private var fasts: [FastingSession]

    @State private var showWater = false
    @State private var showFasting = false

    init(date: Date, profile: UserProfile?) {
        self.date = date
        self.profile = profile
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        _entries = Query(filter: #Predicate<FoodEntry> { $0.loggedAt >= start && $0.loggedAt < end },
                         sort: \FoodEntry.loggedAt)
        _waters = Query(filter: #Predicate<WaterLog> { $0.day == start })
        _fasts = Query(sort: \FastingSession.startAt, order: .reverse)
    }

    // Derived totals
    private var consumed: Int { entries.reduce(0) { $0 + $1.totalKcal } }
    private var protein: Int { entries.reduce(0) { $0 + $1.protein } }
    private var carbs: Int { entries.reduce(0) { $0 + $1.carbs } }
    private var fat: Int { entries.reduce(0) { $0 + $1.fat } }
    private var waterTotal: Int { waters.reduce(0) { $0 + $1.amountMl } }
    private var activeFast: FastingSession? { fasts.first { $0.state == .active } }

    private var target: Int { profile?.calorieTarget ?? 2000 }
    private var waterGoal: Int { profile?.waterGoalMl ?? 2500 }
    private var displayMode: CaloriesDisplayMode { profile?.caloriesDisplayMode ?? .remaining }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            heroCard
            MascotBanner(mascotName: profile?.mascotName ?? "Buddy",
                         remaining: target - consumed, target: target)
            statsRow
            mealsList
        }
        .sheet(isPresented: $showWater) {
            WaterView(date: date)
        }
        .sheet(isPresented: $showFasting) {
            FastingView()
        }
    }

    // MARK: Hero

    private var heroCard: some View {
        VStack(spacing: Spacing.lg) {
            CalorieRing(consumed: consumed, target: target, mode: displayMode)
                .frame(width: 190, height: 190)
            MacroBars(protein: protein, carbs: carbs, fat: fat,
                      proteinTarget: profile?.proteinTargetG ?? 150,
                      carbsTarget: profile?.carbTargetG ?? 200,
                      fatTarget: profile?.fatTargetG ?? 67)
        }
        .frame(maxWidth: .infinity)
        .cbCard()
    }

    // MARK: Stats

    private var statsRow: some View {
        HStack(spacing: Spacing.md) {
            DayStatCard(icon: "drop.fill", tint: Theme.water,
                        value: "\(waterTotal) ml", label: "of \(waterGoal) ml",
                        progress: waterGoal > 0 ? Double(waterTotal) / Double(waterGoal) : 0,
                        addAction: { addWater(250) },
                        tapAction: { showWater = true })

            DayStatCard(icon: "timer", tint: Theme.grape,
                        value: fastingValue, label: fastingLabel,
                        tapAction: { showFasting = true })
        }
    }

    private var fastingValue: String {
        guard let fast = activeFast else { return "Start" }
        let hours = Int(fast.elapsed() / 3600)
        let minutes = Int(fast.elapsed().truncatingRemainder(dividingBy: 3600) / 60)
        return String(format: "%02d:%02d", hours, minutes)
    }
    private var fastingLabel: String {
        activeFast == nil ? "Tap to fast" : "Fasting now"
    }

    // MARK: Meals

    private var mealsList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(MealType.allCases.sorted { $0.sortOrder < $1.sortOrder }) { meal in
                MealSectionView(
                    meal: meal,
                    entries: entries.filter { $0.mealType == meal },
                    onAdd: { appState.presentScanner() },
                    onDelete: { delete($0) }
                )
            }
        }
    }

    // MARK: Actions

    private func addWater(_ ml: Int) {
        let log = WaterLog(amountMl: ml, loggedAt: .now)
        context.insert(log)
        try? context.save()
        Task { await health.saveWater(ml: ml) }
        Haptics.tap()
    }

    private func delete(_ entry: FoodEntry) {
        context.delete(entry)
        try? context.save()
        Haptics.warning()
    }
}
