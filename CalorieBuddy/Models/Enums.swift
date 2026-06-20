//
//  Enums.swift
//  CalorieBuddy
//
//  Domain enums. Stored in SwiftData as raw String values (CloudKit-safe) and
//  surfaced on models via computed accessors.
//

import Foundation

// MARK: - Body / profile

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male, female, other
    var id: String { rawValue }
    var title: String {
        switch self {
        case .male: "Male"
        case .female: "Female"
        case .other: "Other"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary, light, moderate, active, veryActive
    var id: String { rawValue }
    var title: String {
        switch self {
        case .sedentary: "Sedentary"
        case .light: "Lightly active"
        case .moderate: "Moderately active"
        case .active: "Active"
        case .veryActive: "Very active"
        }
    }
    var subtitle: String {
        switch self {
        case .sedentary: "Little or no exercise"
        case .light: "Exercise 1–3 days / week"
        case .moderate: "Exercise 3–5 days / week"
        case .active: "Exercise 6–7 days / week"
        case .veryActive: "Hard exercise or a physical job"
        }
    }
    /// Mifflin-St Jeor TDEE multiplier.
    var factor: Double {
        switch self {
        case .sedentary: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .active: 1.725
        case .veryActive: 1.9
        }
    }
    var systemImage: String {
        switch self {
        case .sedentary: "sofa.fill"
        case .light: "figure.walk"
        case .moderate: "figure.run"
        case .active: "figure.run.treadmill"
        case .veryActive: "figure.strengthtraining.traditional"
        }
    }
}

enum Goal: String, Codable, CaseIterable, Identifiable {
    case lose, maintain, gain
    var id: String { rawValue }
    var title: String {
        switch self {
        case .lose: "Lose weight"
        case .maintain: "Maintain weight"
        case .gain: "Gain weight"
        }
    }
    /// Sign applied to the weekly weight delta (kcal direction).
    var direction: Double {
        switch self {
        case .lose: -1
        case .maintain: 0
        case .gain: 1
        }
    }
    var systemImage: String {
        switch self {
        case .lose: "arrow.down.right"
        case .maintain: "equal"
        case .gain: "arrow.up.right"
        }
    }
}

enum GoalPace: String, Codable, CaseIterable, Identifiable {
    case relaxed, steady, ambitious
    var id: String { rawValue }
    /// Target body-weight change per week, in kilograms.
    var kgPerWeek: Double {
        switch self {
        case .relaxed: 0.25
        case .steady: 0.5
        case .ambitious: 0.75
        }
    }
    var title: String {
        switch self {
        case .relaxed: "Relaxed"
        case .steady: "Steady"
        case .ambitious: "Ambitious"
        }
    }
}

enum DietType: String, Codable, CaseIterable, Identifiable {
    case classic, balanced, lowCarb, keto, highProtein, vegetarian, vegan, pescatarian, mediterranean
    var id: String { rawValue }
    var title: String {
        switch self {
        case .classic: "Classic"
        case .balanced: "Balanced"
        case .lowCarb: "Low carb"
        case .keto: "Keto"
        case .highProtein: "High protein"
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        case .pescatarian: "Pescatarian"
        case .mediterranean: "Mediterranean"
        }
    }
    /// Fraction of calories from (protein, carbs, fat). Sums to ~1.0.
    var macroSplit: (p: Double, c: Double, f: Double) {
        switch self {
        case .classic, .balanced: (0.30, 0.40, 0.30)
        case .lowCarb: (0.35, 0.20, 0.45)
        case .keto: (0.25, 0.05, 0.70)
        case .highProtein: (0.40, 0.35, 0.25)
        case .vegetarian: (0.25, 0.50, 0.25)
        case .vegan: (0.22, 0.55, 0.23)
        case .pescatarian: (0.30, 0.40, 0.30)
        case .mediterranean: (0.25, 0.45, 0.30)
        }
    }
    var emoji: String {
        switch self {
        case .classic: "🍽️"
        case .balanced: "⚖️"
        case .lowCarb: "🥩"
        case .keto: "🥑"
        case .highProtein: "💪"
        case .vegetarian: "🥗"
        case .vegan: "🌱"
        case .pescatarian: "🐟"
        case .mediterranean: "🫒"
        }
    }
}

// MARK: - Logging

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack
    var id: String { rawValue }
    var title: String {
        switch self {
        case .breakfast: "Breakfast"
        case .lunch: "Lunch"
        case .dinner: "Dinner"
        case .snack: "Snack"
        }
    }
    var systemImage: String {
        switch self {
        case .breakfast: "sunrise.fill"
        case .lunch: "sun.max.fill"
        case .dinner: "moon.stars.fill"
        case .snack: "carrot.fill"
        }
    }
    var sortOrder: Int {
        switch self {
        case .breakfast: 0
        case .lunch: 1
        case .dinner: 2
        case .snack: 3
        }
    }
    /// Best-guess meal for a given time of day.
    static func suggested(for date: Date = .now) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 4..<11: return .breakfast
        case 11..<15: return .lunch
        case 17..<22: return .dinner
        default: return .snack
        }
    }
}

enum FoodSource: String, Codable {
    case aiPhoto, aiLabel, barcode, manual, favorite
    var label: String {
        switch self {
        case .aiPhoto: "AI photo"
        case .aiLabel: "Label scan"
        case .barcode: "Barcode"
        case .manual: "Manual"
        case .favorite: "Saved food"
        }
    }
    var systemImage: String {
        switch self {
        case .aiPhoto: "camera.fill"
        case .aiLabel: "doc.text.viewfinder"
        case .barcode: "barcode.viewfinder"
        case .manual: "square.and.pencil"
        case .favorite: "star.fill"
        }
    }
}

enum FastingState: String, Codable {
    case active, completed, canceled
}

// MARK: - Preferences

enum MeasurementSystem: String, Codable, CaseIterable, Identifiable {
    case metric, imperial
    var id: String { rawValue }
    var title: String {
        switch self {
        case .metric: "Metric (kg, cm)"
        case .imperial: "Imperial (lb, ft)"
        }
    }
}

enum CaloriesDisplayMode: String, Codable, CaseIterable, Identifiable {
    case remaining, consumed
    var id: String { rawValue }
    var title: String {
        switch self {
        case .remaining: "Calories remaining"
        case .consumed: "Calories eaten"
        }
    }
}
