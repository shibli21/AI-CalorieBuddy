//
//  Diary.swift
//  CalorieBuddy
//
//  The food-logging cluster: a DiaryDay aggregates FoodEntry items, each of
//  which is composed of Ingredient items. CloudKit-safe (defaults + optional
//  relationships, inverse declared on one side only).
//

import Foundation
import SwiftData

@Model
final class DiaryDay {
    var id: UUID = UUID()
    /// Normalized to the start of the day (local).
    var date: Date = Calendar.current.startOfDay(for: .now)
    /// Active energy pulled from HealthKit (kcal).
    var burnedKcal: Int = 0
    /// 0–100 nutrition quality score for the day.
    var nutritionScore: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.day)
    var entries: [FoodEntry]? = nil

    init(date: Date = .now) {
        self.date = Calendar.current.startOfDay(for: date)
    }

    var entriesList: [FoodEntry] {
        (entries ?? []).sorted { $0.loggedAt < $1.loggedAt }
    }
    var consumedKcal: Int { entriesList.reduce(0) { $0 + $1.totalKcal } }
    var protein: Int { entriesList.reduce(0) { $0 + $1.protein } }
    var carbs: Int { entriesList.reduce(0) { $0 + $1.carbs } }
    var fat: Int { entriesList.reduce(0) { $0 + $1.fat } }
    var fiber: Int { entriesList.reduce(0) { $0 + $1.fiber } }

    func entries(for meal: MealType) -> [FoodEntry] {
        entriesList.filter { $0.mealType == meal }
    }
}

@Model
final class FoodEntry {
    var id: UUID = UUID()
    var name: String = ""
    var loggedAt: Date = Date.now
    var mealTypeRaw: String = MealType.snack.rawValue
    var sourceRaw: String = FoodSource.manual.rawValue

    var totalKcal: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
    var fiber: Int = 0
    var servingDesc: String = ""
    /// AI confidence 0–1 (1 for manual entries).
    var confidence: Double = 1.0
    /// Compressed meal photo (managed as a CKAsset by SwiftData+CloudKit).
    var photoData: Data? = nil

    var day: DiaryDay? = nil

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.entry)
    var ingredients: [Ingredient]? = nil

    init(name: String = "",
         mealType: MealType = .snack,
         source: FoodSource = .manual,
         loggedAt: Date = .now) {
        self.name = name
        self.mealTypeRaw = mealType.rawValue
        self.sourceRaw = source.rawValue
        self.loggedAt = loggedAt
    }

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .snack }
        set { mealTypeRaw = newValue.rawValue }
    }
    var source: FoodSource {
        get { FoodSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }
    var ingredientsList: [Ingredient] { ingredients ?? [] }

    /// Recompute macro totals from ingredients (used after editing). Zeroes the
    /// totals when there are no ingredients, so deleting the last ingredient
    /// can't leave phantom calories. Callers that hold hand-entered totals with
    /// no ingredients (manual entries) should avoid calling this — see
    /// FoodEditView, which only recalculates ingredient-backed entries.
    func recalcFromIngredients() {
        let items = ingredientsList
        totalKcal = items.reduce(0) { $0 + $1.kcal }
        protein = items.reduce(0) { $0 + $1.protein }
        carbs = items.reduce(0) { $0 + $1.carbs }
        fat = items.reduce(0) { $0 + $1.fat }
        fiber = items.reduce(0) { $0 + $1.fiber }
    }
}

@Model
final class Ingredient {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 1
    var unit: String = "serving"
    var kcal: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
    var fiber: Int = 0

    var entry: FoodEntry? = nil

    init(name: String = "",
         quantity: Double = 1,
         unit: String = "serving",
         kcal: Int = 0,
         protein: Int = 0,
         carbs: Int = 0,
         fat: Int = 0,
         fiber: Int = 0) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
    }

    var portionLabel: String {
        let q = quantity == quantity.rounded() ? String(Int(quantity)) : String(format: "%.1f", quantity)
        return "\(q) \(unit)"
    }
}
