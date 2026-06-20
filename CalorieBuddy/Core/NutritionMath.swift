//
//  NutritionMath.swift
//  CalorieBuddy
//
//  Pure functions for energy/macro/water targets. No side effects — easy to
//  unit-test and safe to call from previews.
//

import Foundation

enum NutritionMath {

    /// Energy yield per gram (Atwater): protein 4, carbs 4, fat 9 kcal/g.
    static let kcalPerGProtein = 4.0
    static let kcalPerGCarb = 4.0
    static let kcalPerGFat = 9.0
    /// Approx. kcal per kg of body mass change.
    static let kcalPerKg = 7700.0
    static let minSafeCalories = 1200

    /// Basal metabolic rate (Mifflin-St Jeor).
    static func bmr(sex: Sex, weightKg: Double, heightCm: Double, age: Int) -> Double {
        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age)
        switch sex {
        case .male: return base + 5
        case .female: return base - 161
        case .other: return base - 78 // midpoint of the two formulas
        }
    }

    static func tdee(bmr: Double, activity: ActivityLevel) -> Double {
        bmr * activity.factor
    }

    /// Daily calorie target, rounded to the nearest 10 and floored at a safe minimum.
    static func calorieTarget(tdee: Double, goal: Goal, pace: GoalPace) -> Int {
        let weeklyDeltaKcal = goal.direction * pace.kgPerWeek * kcalPerKg
        let daily = tdee + weeklyDeltaKcal / 7.0
        let rounded = (daily / 10).rounded() * 10
        return max(minSafeCalories, Int(rounded))
    }

    /// Macro grams from a calorie target and diet split.
    static func macros(calories: Int, diet: DietType) -> (p: Int, c: Int, f: Int) {
        let split = diet.macroSplit
        let cals = Double(calories)
        let p = Int((cals * split.p / kcalPerGProtein).rounded())
        let c = Int((cals * split.c / kcalPerGCarb).rounded())
        let f = Int((cals * split.f / kcalPerGFat).rounded())
        return (p, c, f)
    }

    /// Recommended daily water (ml), rounded to the nearest 50.
    static func waterGoalMl(weightKg: Double, activity: ActivityLevel) -> Int {
        let base = weightKg * 35.0
        let bonus = max(0, activity.factor - 1.2) * 500.0
        let total = base + bonus
        return Int((total / 50).rounded() * 50)
    }

    static func age(from birthDate: Date, now: Date = .now) -> Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: now).year ?? 28
    }

    static func bmi(weightKg: Double, heightCm: Double) -> Double {
        guard heightCm > 0 else { return 0 }
        let m = heightCm / 100.0
        return weightKg / (m * m)
    }

    static func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: "Underweight"
        case 18.5..<25: "Healthy"
        case 25..<30: "Overweight"
        default: "Obese"
        }
    }

    /// Estimated calendar weeks to reach the target weight at the chosen pace.
    static func weeksToGoal(currentKg: Double, targetKg: Double, pace: GoalPace) -> Int {
        let delta = abs(currentKg - targetKg)
        guard pace.kgPerWeek > 0, delta > 0 else { return 0 }
        return Int((delta / pace.kgPerWeek).rounded(.up))
    }

    /// Projected goal date from today.
    static func projectedGoalDate(currentKg: Double, targetKg: Double, pace: GoalPace, from: Date = .now) -> Date {
        let weeks = weeksToGoal(currentKg: currentKg, targetKg: targetKg, pace: pace)
        return Calendar.current.date(byAdding: .day, value: weeks * 7, to: from) ?? from
    }
}
