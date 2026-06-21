//
//  AIInsightCard.swift
//  CalorieBuddy
//
//  A reusable, cached, user-initiated AI insight card (insights task). Used for a
//  daily summary on the Diary and a weekly summary on Stats. Generation is always
//  user-triggered (a button) so it never silently spends; results are cached per
//  period in UserDefaults and can be refreshed. Demo result when unconfigured.
//

import SwiftUI

/// Cached insight plus a fingerprint of the data it summarized, so a cached
/// insight is dropped once the underlying meals change.
private struct CachedInsight: Codable {
    var insight: AIInsight
    var signature: String
}

struct AIInsightCard: View {
    let scope: String                 // "day" | "week"
    let title: String
    let cacheKey: String              // unique per period, e.g. "2026-06-21"
    /// Cheap fingerprint of the summarized data (e.g. count + total kcal). When it
    /// changes, the cached insight is considered stale and dropped.
    let signature: String
    let contextBuilder: () -> AIContext

    @Environment(AIService.self) private var ai
    @State private var insight: AIInsight?
    @State private var loading = false
    @State private var errorMessage: String?
    @State private var loadedCache = false

    private var udKey: String { "cb.insight.\(scope).\(cacheKey)" }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            header
            if loading {
                loadingRow
            } else if let insight, !insight.isEmpty {
                content(insight)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
                generateButton(label: "Try again")
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
        .onAppear(perform: loadCache)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "sparkles").foregroundStyle(Theme.accent)
            Text(title).font(CBFont.headline).foregroundStyle(Theme.ink)
            Spacer()
            if insight != nil && !loading {
                Button {
                    Haptics.tap()
                    generate()
                } label: {
                    Image(systemName: "arrow.clockwise").font(.subheadline).foregroundStyle(Theme.inkSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Refresh insight")
            }
        }
    }

    // MARK: States

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Get a quick AI read on your \(scope == "week" ? "week" : "day").")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
            if !ai.isConfigured {
                Label("Demo mode — add a proxy URL to enable real AI.", systemImage: "info.circle")
                    .font(CBFont.caption2)
                    .foregroundStyle(Theme.inkTertiary)
            }
            generateButton(label: "Generate insight")
        }
    }

    private var loadingRow: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
            Text("Thinking…").font(CBFont.subheadline).foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.xs)
    }

    private func generateButton(label: String) -> some View {
        Button {
            Haptics.tap()
            generate()
        } label: {
            Label(label, systemImage: "sparkles")
                .font(CBFont.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.accent, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func content(_ insight: AIInsight) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if !insight.headline.isEmpty {
                Text(insight.headline).font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
            }
            if !insight.summary.isEmpty {
                Text(insight.summary)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !insight.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(insight.highlights, id: \.self) { line in
                        bullet(icon: "checkmark.circle.fill", tint: Theme.accent, text: line)
                    }
                }
            }
            if !insight.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(insight.suggestions, id: \.self) { line in
                        bullet(icon: "lightbulb.fill", tint: Theme.amber, text: line)
                    }
                }
            }
        }
    }

    private func bullet(icon: String, tint: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Image(systemName: icon).font(.caption).foregroundStyle(tint).padding(.top, 2)
            Text(text)
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Logic

    private func loadCache() {
        guard !loadedCache else { return }
        loadedCache = true
        if let data = UserDefaults.standard.data(forKey: udKey),
           let cached = try? JSONDecoder().decode(CachedInsight.self, from: data),
           cached.signature == signature {        // ignore if the data has changed
            insight = cached.insight
        }
    }

    private func saveCache(_ value: AIInsight) {
        if let data = try? JSONEncoder().encode(CachedInsight(insight: value, signature: signature)) {
            UserDefaults.standard.set(data, forKey: udKey)
        }
    }

    private func generate() {
        loading = true
        errorMessage = nil
        Task {
            do {
                let result: AIInsight
                if ai.isConfigured {
                    result = try await ai.insights(context: contextBuilder(), scope: scope)
                } else {
                    #if DEBUG
                    try? await Task.sleep(for: .seconds(1.0))
                    result = AIService.mockInsight()
                    #else
                    throw AIError.notConfigured
                    #endif
                }
                insight = result
                saveCache(result)
                loading = false
                Haptics.success()
            } catch {
                errorMessage = (error as? AIError)?.errorDescription ?? error.localizedDescription
                loading = false
                Haptics.error()
            }
        }
    }
}

// MARK: - Context builders

/// Builds the JSON snapshot the model reads. Keep field names stable and human-readable.
enum AIInsightContext {
    static func day(entries: [FoodEntry], profile: UserProfile?) -> AIContext {
        let consumed = entries.reduce(0) { $0 + $1.totalKcal }
        let protein = entries.reduce(0) { $0 + $1.protein }
        let carbs = entries.reduce(0) { $0 + $1.carbs }
        let fat = entries.reduce(0) { $0 + $1.fat }
        let fiber = entries.reduce(0) { $0 + $1.fiber }
        let target = profile?.calorieTarget ?? 0
        let score = target > 0 ? NutritionScore.dayScore(consumed: consumed, target: target, protein: protein, fiber: fiber) : nil
        return AIContext(
            goal: profile?.goal.title,
            dietType: profile?.dietType.title,
            calorieTarget: target > 0 ? target : nil,
            consumed: consumed,
            remaining: target > 0 ? max(0, target - consumed) : nil,
            protein: protein, carbs: carbs, fat: fat, fiber: fiber,
            proteinTarget: profile?.proteinTargetG,
            nutritionScore: score,
            meals: entries.map {
                AIContextMeal(name: $0.name.isEmpty ? "Meal" : $0.name, mealType: $0.mealType.title, kcal: $0.totalKcal)
            },
            recentDays: nil
        )
    }

    static func week(entries: [FoodEntry], days range: Int, profile: UserProfile?) -> AIContext {
        let cal = Calendar.current
        let target = profile?.calorieTarget ?? 0
        let grouped = Dictionary(grouping: entries) { cal.startOfDay(for: $0.loggedAt) }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        var recent: [AIContextDay] = []
        for offset in stride(from: range - 1, through: 0, by: -1) {
            guard let day = cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: .now)) else { continue }
            let dayEntries = grouped[day] ?? []
            let k = dayEntries.reduce(0) { $0 + $1.totalKcal }
            let p = dayEntries.reduce(0) { $0 + $1.protein }
            let f = dayEntries.reduce(0) { $0 + $1.fiber }
            let score = target > 0 ? NutritionScore.dayScore(consumed: k, target: target, protein: p, fiber: f) : 0
            recent.append(AIContextDay(date: fmt.string(from: day), kcal: k, score: score))
        }
        return AIContext(
            goal: profile?.goal.title,
            dietType: profile?.dietType.title,
            calorieTarget: target > 0 ? target : nil,
            consumed: nil, remaining: nil,
            protein: nil, carbs: nil, fat: nil, fiber: nil,
            proteinTarget: profile?.proteinTargetG,
            nutritionScore: nil,
            meals: nil,
            recentDays: recent
        )
    }

    /// Stable cache key for a date (the period the insight summarizes).
    static func dayKey(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Calendar.current.startOfDay(for: date))
    }

    /// Cheap fingerprint of the data an insight summarizes. Changes when meals are
    /// added/edited/removed, so a cached insight is invalidated rather than shown stale.
    static func signature(entries: [FoodEntry]) -> String {
        let total = entries.reduce(0) { $0 + $1.totalKcal }
        return "\(entries.count)-\(total)"
    }
}
