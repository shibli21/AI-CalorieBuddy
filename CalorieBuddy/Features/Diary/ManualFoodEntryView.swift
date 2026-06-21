//
//  ManualFoodEntryView.swift
//  CalorieBuddy
//
//  Log a custom food by hand.
//

import SwiftUI
import SwiftData

struct ManualFoodEntryView: View {
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(HealthKitService.self) private var health
    @Environment(AppState.self) private var appState
    @Query private var streaks: [Streak]

    @State private var name = ""
    @State private var meal: MealType = .suggested()
    @State private var serving = ""
    @State private var kcal = 0
    @State private var protein = 0
    @State private var carbs = 0
    @State private var fat = 0
    @State private var fiber = 0

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Name", text: $name)
                    Picker("Meal", selection: $meal) {
                        ForEach(MealType.allCases) { Text($0.title).tag($0) }
                    }
                    TextField("Serving (e.g. 1 bowl)", text: $serving)
                }
                Section("Nutrition") {
                    numberField("Calories", value: $kcal, unit: "kcal")
                    numberField("Protein", value: $protein, unit: "g")
                    numberField("Carbs", value: $carbs, unit: "g")
                    numberField("Fat", value: $fat, unit: "g")
                    numberField("Fiber", value: $fiber, unit: "g")
                }
            }
            .navigationTitle("Add food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }.disabled(!canSave)
                }
            }
        }
    }

    private func numberField(_ label: String, value: Binding<Int>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(unit).foregroundStyle(.secondary)
        }
    }

    private func save() {
        let when = DiaryStore.timestamp(for: date)
        let entry = FoodEntry(name: name, mealType: meal, source: .manual, loggedAt: when)
        entry.servingDesc = serving
        entry.totalKcal = kcal
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.fiber = fiber
        entry.day = DiaryStore.day(for: when, in: context)
        context.insert(entry)
        let advanced = DiaryStore.registerStreak(streaks.first, on: when)
        try? context.save()
        Task { await health.save(foodEntry: entry) }
        Haptics.success()
        dismiss()
        if let advanced { appState.celebrationDay = advanced }
    }
}
