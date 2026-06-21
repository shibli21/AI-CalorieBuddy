//
//  UserProfile.swift
//  CalorieBuddy
//
//  The single per-user profile + computed plan. One instance per install
//  (synced via CloudKit). All stored properties have defaults so the model
//  is CloudKit-compatible.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var createdAt: Date = Date.now

    // Identity & body metrics
    var sexRaw: String = Sex.other.rawValue
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now
    var heightCm: Double = 170
    var startWeightKg: Double = 75
    var currentWeightKg: Double = 75
    var targetWeightKg: Double = 68

    // Goal
    var activityLevelRaw: String = ActivityLevel.moderate.rawValue
    var goalRaw: String = Goal.lose.rawValue
    var goalPaceRaw: String = GoalPace.steady.rawValue
    var dietTypeRaw: String = DietType.classic.rawValue
    var restrictions: [String] = []

    // Computed daily plan (persisted so it survives offline / is editable)
    var calorieTarget: Int = 2000
    var proteinTargetG: Int = 150
    var carbTargetG: Int = 200
    var fatTargetG: Int = 67
    var waterGoalMl: Int = 2500
    var fastingPresetHours: Int = 16

    // Preferences
    var measurementSystemRaw: String = MeasurementSystem.metric.rawValue
    var caloriesDisplayRaw: String = CaloriesDisplayMode.remaining.rawValue
    var dashboardBackgroundRaw: String = DashboardBackground.default.rawValue
    var mascotName: String = "Buddy"
    var remindersEnabled: Bool = false
    var reminderHour: Int = 19
    var onboardingCompleted: Bool = false

    init() {}

    // MARK: - Enum accessors

    var sex: Sex {
        get { Sex(rawValue: sexRaw) ?? .other }
        set { sexRaw = newValue.rawValue }
    }
    var activityLevel: ActivityLevel {
        get { ActivityLevel(rawValue: activityLevelRaw) ?? .moderate }
        set { activityLevelRaw = newValue.rawValue }
    }
    var goal: Goal {
        get { Goal(rawValue: goalRaw) ?? .lose }
        set { goalRaw = newValue.rawValue }
    }
    var goalPace: GoalPace {
        get { GoalPace(rawValue: goalPaceRaw) ?? .steady }
        set { goalPaceRaw = newValue.rawValue }
    }
    var dietType: DietType {
        get { DietType(rawValue: dietTypeRaw) ?? .classic }
        set { dietTypeRaw = newValue.rawValue }
    }
    var measurementSystem: MeasurementSystem {
        get { MeasurementSystem(rawValue: measurementSystemRaw) ?? .metric }
        set { measurementSystemRaw = newValue.rawValue }
    }
    var caloriesDisplayMode: CaloriesDisplayMode {
        get { CaloriesDisplayMode(rawValue: caloriesDisplayRaw) ?? .remaining }
        set { caloriesDisplayRaw = newValue.rawValue }
    }
    var dashboardBackground: DashboardBackground {
        get { DashboardBackground(rawValue: dashboardBackgroundRaw) ?? .default }
        set { dashboardBackgroundRaw = newValue.rawValue }
    }

    // MARK: - Derived

    var age: Int { NutritionMath.age(from: birthDate) }
    var bmi: Double { NutritionMath.bmi(weightKg: currentWeightKg, heightCm: heightCm) }

    /// Recomputes the daily plan from the current metrics and goal.
    func recomputePlan() {
        let bmr = NutritionMath.bmr(sex: sex, weightKg: currentWeightKg, heightCm: heightCm, age: age)
        let tdee = NutritionMath.tdee(bmr: bmr, activity: activityLevel)
        calorieTarget = NutritionMath.calorieTarget(tdee: tdee, goal: goal, pace: goalPace)
        let macros = NutritionMath.macros(calories: calorieTarget, diet: dietType)
        proteinTargetG = macros.p
        carbTargetG = macros.c
        fatTargetG = macros.f
        waterGoalMl = NutritionMath.waterGoalMl(weightKg: currentWeightKg, activity: activityLevel)
    }
}
