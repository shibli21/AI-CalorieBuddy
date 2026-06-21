//
//  DiaryDayContent.swift
//  CalorieBuddy
//
//  The day-scoped diary: summary, add actions, recents quick re-log, and the
//  per-meal log.
//

import SwiftUI
import SwiftData

struct DiaryDayContent: View {
    let date: Date
    let profile: UserProfile?
    var onAddManual: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Environment(HealthKitService.self) private var health

    @Query private var entries: [FoodEntry]
    @Query private var recentEntries: [FoodEntry]
    @Query private var streaks: [Streak]

    init(date: Date, profile: UserProfile?, onAddManual: @escaping () -> Void) {
        self.date = date
        self.profile = profile
        self.onAddManual = onAddManual
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        _entries = Query(filter: #Predicate<FoodEntry> { $0.loggedAt >= start && $0.loggedAt < end },
                         sort: \FoodEntry.loggedAt)
        var recentDescriptor = FetchDescriptor<FoodEntry>(sortBy: [SortDescriptor(\.loggedAt, order: .reverse)])
        recentDescriptor.fetchLimit = 50
        _recentEntries = Query(recentDescriptor)
    }

    private var consumed: Int { entries.reduce(0) { $0 + $1.totalKcal } }
    private var target: Int { profile?.calorieTarget ?? 2000 }

    /// Recent distinct foods (by name) for quick re-logging.
    private var recents: [FoodEntry] {
        var seen = Set<String>()
        var result: [FoodEntry] = []
        for entry in recentEntries {
            let key = entry.name.lowercased()
            if key.isEmpty || seen.contains(key) { continue }
            seen.insert(key)
            result.append(entry)
            if result.count >= 8 { break }
        }
        return result
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            summaryBar
            addBar
            if !recents.isEmpty { recentsSection }
            ForEach(MealType.allCases.sorted { $0.sortOrder < $1.sortOrder }) { meal in
                MealSectionView(
                    meal: meal,
                    entries: entries.filter { $0.mealType == meal },
                    onAdd: onAddManual,
                    onDelete: delete
                )
            }
        }
    }

    private var summaryBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(consumed) / \(target) kcal")
                    .font(CBFont.title3)
                    .foregroundStyle(Theme.ink)
                Text("\(max(0, target - consumed)) kcal remaining")
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer()
            ProgressRing(progress: target > 0 ? Double(consumed) / Double(target) : 0, lineWidth: 8)
                .frame(width: 48, height: 48)
        }
        .cbCard()
    }

    private var addBar: some View {
        HStack(spacing: Spacing.md) {
            Button {
                appState.presentScanner()
            } label: {
                Label("Scan", systemImage: "camera.fill")
                    .font(CBFont.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accent, in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                Haptics.tap()
                onAddManual()
            } label: {
                Label("Add manually", systemImage: "square.and.pencil")
                    .font(CBFont.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.surfaceAlt, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent foods").font(CBFont.headline).foregroundStyle(Theme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(recents) { food in
                        Button { reLog(food) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name).font(CBFont.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.ink).lineLimit(1)
                                Text("\(food.totalKcal) kcal").font(CBFont.caption2).foregroundStyle(Theme.inkSecondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .frame(width: 140, alignment: .leading)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "plus.circle.fill").foregroundStyle(Theme.accent).padding(6)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    // MARK: Actions

    private func reLog(_ template: FoodEntry) {
        let when = DiaryStore.timestamp(for: date)
        let entry = FoodEntry(name: template.name,
                              mealType: MealType.suggested(for: when),
                              source: .favorite,
                              loggedAt: when)
        entry.totalKcal = template.totalKcal
        entry.protein = template.protein
        entry.carbs = template.carbs
        entry.fat = template.fat
        entry.fiber = template.fiber
        entry.servingDesc = template.servingDesc
        entry.ingredients = template.ingredientsList.map {
            Ingredient(name: $0.name, quantity: $0.quantity, unit: $0.unit,
                       kcal: $0.kcal, protein: $0.protein, carbs: $0.carbs, fat: $0.fat, fiber: $0.fiber)
        }
        entry.day = DiaryStore.day(for: when, in: context)
        context.insert(entry)
        if let advanced = DiaryStore.registerStreak(streaks.first, on: when, in: context) {
            appState.celebrationDay = advanced
        }
        try? context.save()
        Task { await health.save(foodEntry: entry) }
        Haptics.success()
    }

    private func delete(_ entry: FoodEntry) {
        context.delete(entry)
        try? context.save()
        Haptics.warning()
    }
}
