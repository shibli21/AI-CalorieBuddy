//
//  FoodDetailView.swift
//  CalorieBuddy
//
//  Full detail for a logged meal: photo, calories/macros, nutrition score,
//  award badges (with education), ingredients, and edit/delete/share.
//

import SwiftUI
import SwiftData

struct FoodDetailView: View {
    let entry: FoodEntry

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteFood]

    @State private var showEdit = false
    @State private var showDelete = false
    @State private var selectedAward: NutritionAward?
    @State private var infoTopic: NutritionInfoTopic?

    private var score: Int { NutritionScore.score(for: entry) }
    private var awards: [NutritionAward] { Awards.awards(for: entry) }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                header
                caloriesCard
                scoreCard
                if !awards.isEmpty { awardsCard }
                ingredientsCard
                deleteButton
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Theme.background)
        .navigationTitle(entry.name.isEmpty ? "Meal" : entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEdit = true } label: { Label("Edit", systemImage: "pencil") }
                    Button { toggleFavorite() } label: {
                        Label(isFavorited ? "Remove favorite" : "Save as favorite",
                              systemImage: isFavorited ? "star.fill" : "star")
                    }
                    ShareLink(item: shareText) { Label("Share", systemImage: "square.and.arrow.up") }
                    Button(role: .destructive) { showDelete = true } label: { Label("Delete", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEdit) { FoodEditView(entry: entry) }
        .sheet(item: $selectedAward) { AwardEducationView(award: $0) }
        .sheet(item: $infoTopic) { NutritionInfoSheet(topic: $0) }
        .alert("Delete this meal?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) { deleteEntry() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    // MARK: Sections

    @ViewBuilder
    private var header: some View {
        if let data = entry.photoData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        }
        HStack(spacing: Spacing.sm) {
            Label(entry.mealType.title, systemImage: entry.mealType.systemImage)
            Text("·")
            Text(entry.loggedAt.formatted(date: .omitted, time: .shortened))
            Spacer()
            Label(entry.source.label, systemImage: entry.source.systemImage)
        }
        .font(CBFont.caption)
        .foregroundStyle(Theme.inkSecondary)
    }

    private var caloriesCard: some View {
        VStack(spacing: Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("\(entry.totalKcal)").font(CBFont.display(40)).foregroundStyle(Theme.ink)
                Text("kcal").font(CBFont.headline).foregroundStyle(Theme.inkSecondary)
                Spacer()
                infoButton(.calories)
            }
            HStack(spacing: Spacing.sm) {
                MacroChip(kind: .protein, grams: entry.protein)
                MacroChip(kind: .carbs, grams: entry.carbs)
                MacroChip(kind: .fat, grams: entry.fat)
            }
            if entry.fiber > 0 {
                HStack {
                    Text("Fiber").font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                    Spacer()
                    Text("\(entry.fiber) g").font(CBFont.caption).foregroundStyle(Theme.ink)
                }
            }
        }
        .cbCard()
    }

    private var scoreCard: some View {
        HStack(spacing: Spacing.lg) {
            ZStack {
                ProgressRing(progress: Double(score) / 100, lineWidth: 9, colors: scoreColors)
                    .frame(width: 64, height: 64)
                Text("\(score)").font(CBFont.headline).foregroundStyle(Theme.ink)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Nutrition score").font(CBFont.subheadline).foregroundStyle(Theme.inkSecondary)
                Text(NutritionScore.grade(score)).font(CBFont.title3).foregroundStyle(Theme.ink)
            }
            Spacer()
            infoButton(.score)
        }
        .cbCard()
    }

    private func infoButton(_ topic: NutritionInfoTopic) -> some View {
        Button { infoTopic = topic } label: {
            Image(systemName: "info.circle").foregroundStyle(Theme.inkTertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("About \(topic.title)")
    }

    private var awardsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Awards").font(CBFont.headline).foregroundStyle(Theme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(awards) { award in
                        Button { selectedAward = award } label: {
                            HStack(spacing: 6) {
                                Text(award.emoji)
                                Text(award.title).font(CBFont.subheadline.weight(.medium)).foregroundStyle(Theme.ink)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Theme.accentSoft, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Ingredients").font(CBFont.headline).foregroundStyle(Theme.ink)
            if entry.ingredientsList.isEmpty {
                Text("No itemized ingredients.").font(CBFont.subheadline).foregroundStyle(Theme.inkTertiary)
            } else {
                ForEach(entry.ingredientsList) { ingredient in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name.isEmpty ? "Item" : ingredient.name)
                                .font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
                            Text(ingredient.portionLabel).font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                        }
                        Spacer()
                        Text("\(ingredient.kcal) kcal").font(CBFont.subheadline).foregroundStyle(Theme.inkSecondary)
                    }
                    if ingredient.id != entry.ingredientsList.last?.id {
                        Divider().overlay(Theme.separator)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDelete = true
        } label: {
            Label("Delete meal", systemImage: "trash")
                .font(CBFont.headline)
                .foregroundStyle(Theme.berry)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.berry.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private var scoreColors: [Color] {
        switch score {
        case 70...: [Theme.accent, Theme.accentDeep]
        case 45..<70: [Theme.amber, Theme.amber]
        default: [Theme.berry, Theme.berry]
        }
    }

    private var shareText: String {
        "\(entry.name.isEmpty ? "Meal" : entry.name) — \(entry.totalKcal) kcal (P\(entry.protein) / C\(entry.carbs) / F\(entry.fat)). Logged with CalorieBuddy."
    }

    private var isFavorited: Bool {
        favorites.contains { $0.name.caseInsensitiveCompare(entry.name) == .orderedSame }
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.name.caseInsensitiveCompare(entry.name) == .orderedSame }) {
            context.delete(existing)
        } else {
            context.insert(FavoriteFood(name: entry.name, totalKcal: entry.totalKcal,
                                        protein: entry.protein, carbs: entry.carbs,
                                        fat: entry.fat, fiber: entry.fiber,
                                        servingDesc: entry.servingDesc))
        }
        try? context.save()
        Haptics.selection()
    }

    private func deleteEntry() {
        context.delete(entry)
        try? context.save()
        Haptics.warning()
        dismiss()
    }
}

// MARK: - Nutrition info sheets

enum NutritionInfoTopic: String, Identifiable {
    case calories, score
    var id: String { rawValue }

    var title: String {
        switch self {
        case .calories: "How calories are estimated"
        case .score: "About the nutrition score"
        }
    }

    var paragraphs: [String] {
        switch self {
        case .calories:
            [
                "CalorieBuddy estimates calories from your photo with AI, then totals the macros: carbohydrate and protein each provide about 4 kcal per gram, and fat about 9 kcal per gram.",
                "These are estimates — portion size and hidden ingredients like oils and sauces can shift the real number. Tap Edit to adjust any item or serving.",
                "Most adults need roughly 1,800–2,400 kcal a day, but your personal target is set from your profile and goal.",
            ]
        case .score:
            [
                "The nutrition score (0–100) rates a meal's quality from its protein density, fiber, and macro balance.",
                "More protein and fiber raise the score; very fat-heavy meals lower it. It's a guide, not a verdict — what matters is balance across the whole day.",
                "Aim for a mix of protein, fiber-rich plants, and healthy fats.",
            ]
        }
    }
}

struct NutritionInfoSheet: View {
    let topic: NutritionInfoTopic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    ForEach(topic.paragraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(CBFont.body)
                            .foregroundStyle(Theme.inkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.screen)
            }
            .background(Theme.background)
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
