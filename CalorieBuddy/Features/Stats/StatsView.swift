//
//  StatsView.swift
//  CalorieBuddy
//
//  Trends: calorie history, weight progress, streaks, and averages. Locked
//  until there are at least a couple of logged days.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \WeightEntry.date) private var weights: [WeightEntry]
    @Query private var entries: [FoodEntry]
    @Query private var streaks: [Streak]
    @State private var range = 7
    @State private var showLogWeight = false
    @State private var showStatsReady = false
    @AppStorage("cb.statsReadySeen") private var statsReadySeen = false

    private var profile: UserProfile? { profiles.first }
    private var target: Int { profile?.calorieTarget ?? 2000 }
    private var streak: Streak? { streaks.first }

    private var loggedDays: Int {
        Set(entries.map { Calendar.current.startOfDay(for: $0.loggedAt) }).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if loggedDays < 2 {
                    lockedState
                } else {
                    VStack(spacing: Spacing.lg) {
                        // Current streak is a free feature (SPEC §3); the full
                        // trends/charts/history are Pro.
                        streakCard
                        ProGate(feature: .stats) {
                            VStack(spacing: Spacing.lg) {
                                rangePicker
                                calorieChartCard
                                weightChartCard
                                averagesCard
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screen)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, 110)
                }
            }
            .background(Theme.background)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showLogWeight = true } label: {
                        Label("Log weight", systemImage: "scalemass")
                    }
                }
            }
            .sheet(isPresented: $showLogWeight) {
                LogWeightSheet(initialKg: profile?.currentWeightKg ?? 70)
            }
            .sheet(isPresented: $showStatsReady) {
                StatsReadyView { statsReadySeen = true }
            }
            .onAppear {
                if loggedDays >= 2 && !statsReadySeen { showStatsReady = true }
            }
        }
    }

    // MARK: Locked

    private var lockedState: some View {
        VStack(spacing: Spacing.md) {
            MascotView(mood: .sleeping, size: 120)
            Text("Keep logging to unlock stats")
                .font(CBFont.title3)
                .foregroundStyle(Theme.ink)
            Text("Log meals for at least 2 days to see your trends, charts, and streaks.")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
            ProgressView(value: Double(loggedDays), total: 2)
                .tint(Theme.accent)
                .frame(maxWidth: 200)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: Controls

    private var rangePicker: some View {
        Picker("Range", selection: $range) {
            Text("7 days").tag(7)
            Text("30 days").tag(30)
            Text("90 days").tag(90)
        }
        .pickerStyle(.segmented)
    }

    private var streakCard: some View {
        HStack(spacing: Spacing.lg) {
            statBlock(value: "\(streak?.current ?? 0)", label: "Day streak", icon: "flame.fill", tint: Theme.amber)
            Divider().frame(height: 40)
            statBlock(value: "\(streak?.longest ?? 0)", label: "Longest", icon: "trophy.fill", tint: Theme.grape)
            Divider().frame(height: 40)
            statBlock(value: "\(loggedDays)", label: "Days logged", icon: "calendar", tint: Theme.accent)
        }
        .cbCard()
    }

    private func statBlock(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(value).font(CBFont.title3).foregroundStyle(Theme.ink)
            Text(label).font(CBFont.caption2).foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Calorie chart

    private var calorieChartCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Calories").font(CBFont.headline).foregroundStyle(Theme.ink)
            Chart {
                ForEach(dailyCalories) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("kcal", item.kcal)
                    )
                    .foregroundStyle(item.kcal > target ? Theme.berry : Theme.accent)
                    .cornerRadius(4)
                }
                RuleMark(y: .value("Target", target))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Theme.inkSecondary)
            }
            .frame(height: 200)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    // MARK: Weight chart

    private var weightChartCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Weight").font(CBFont.headline).foregroundStyle(Theme.ink)
            if weightInRange.count < 2 {
                Button { showLogWeight = true } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "scalemass").font(.title2).foregroundStyle(Theme.accent)
                        Text("Log your weight to see your trend.")
                            .font(CBFont.subheadline)
                            .foregroundStyle(Theme.inkSecondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                }
                .buttonStyle(.plain)
            } else {
                Chart {
                    ForEach(weightInRange) { entry in
                        LineMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("kg", entry.weightKg)
                        )
                        .foregroundStyle(Theme.accent)
                        .interpolationMethod(.catmullRom)
                        PointMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("kg", entry.weightKg)
                        )
                        .foregroundStyle(Theme.accent)
                    }
                    if let goal = profile?.targetWeightKg {
                        RuleMark(y: .value("Goal", goal))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(Theme.grape)
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    // MARK: Averages

    private var averagesCard: some View {
        let avg = dailyCalories.isEmpty ? 0 : dailyCalories.map(\.kcal).reduce(0, +) / max(1, dailyCalories.filter { $0.kcal > 0 }.count)
        return HStack(spacing: Spacing.lg) {
            statBlock(value: "\(avg)", label: "Avg kcal/day", icon: "chart.bar.fill", tint: Theme.accent)
            Divider().frame(height: 40)
            statBlock(value: weightDeltaText, label: "Weight change", icon: "arrow.up.arrow.down", tint: Theme.sky)
        }
        .cbCard()
    }

    private var weightDeltaText: String {
        guard let first = weightInRange.first?.weightKg, let last = weightInRange.last?.weightKg else { return "—" }
        let delta = last - first
        return String(format: "%+.1f kg", delta)
    }

    // MARK: Data

    private var rangeStart: Date {
        Calendar.current.date(byAdding: .day, value: -(range - 1), to: Calendar.current.startOfDay(for: .now)) ?? .now
    }

    private var dailyCalories: [DayKcal] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: entries) { cal.startOfDay(for: $0.loggedAt) }
        return (0..<range).compactMap { offset -> DayKcal? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: .now)) else { return nil }
            let kcal = grouped[day]?.reduce(0) { $0 + $1.totalKcal } ?? 0
            return DayKcal(date: day, kcal: kcal)
        }
        .sorted { $0.date < $1.date }
    }

    private var weightInRange: [WeightEntry] {
        weights.filter { $0.date >= rangeStart }
    }
}

private struct DayKcal: Identifiable {
    var date: Date
    var kcal: Int
    var id: Date { date }
}

#Preview {
    StatsView()
        .environment(AppState())
        .environment(StoreService())
        .modelContainer(AppContainer.preview)
}
