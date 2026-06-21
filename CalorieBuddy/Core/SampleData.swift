//
//  SampleData.swift
//  CalorieBuddy
//
//  Seeds an in-memory context for SwiftUI previews (AppContainer.preview).
//  Not used by the live app — the real store starts empty.
//

import Foundation
import SwiftData

enum SampleData {

    @MainActor
    static func populate(_ context: ModelContext) {
        // Profile
        let profile = UserProfile()
        profile.sex = .female
        profile.heightCm = 168
        profile.startWeightKg = 72
        profile.currentWeightKg = 70.4
        profile.targetWeightKg = 63
        profile.activityLevel = .light
        profile.goal = .lose
        profile.goalPace = .steady
        profile.dietType = .balanced
        profile.mascotName = "Mochi"
        profile.onboardingCompleted = true
        profile.recomputePlan()
        context.insert(profile)

        // Today's diary
        let today = DiaryDay(date: .now)
        today.burnedKcal = 420
        today.nutritionScore = 78
        context.insert(today)

        let breakfast = FoodEntry(name: "Greek yogurt & berries", mealType: .breakfast, source: .aiPhoto, loggedAt: at(hour: 8))
        breakfast.totalKcal = 310; breakfast.protein = 22; breakfast.carbs = 38; breakfast.fat = 8; breakfast.fiber = 6
        breakfast.servingDesc = "1 bowl"
        breakfast.confidence = 0.92
        breakfast.day = today
        breakfast.ingredients = [
            Ingredient(name: "Greek yogurt", quantity: 200, unit: "g", kcal: 180, protein: 18, carbs: 9, fat: 5),
            Ingredient(name: "Blueberries", quantity: 80, unit: "g", kcal: 45, protein: 1, carbs: 11, fat: 0, fiber: 3),
            Ingredient(name: "Granola", quantity: 25, unit: "g", kcal: 85, protein: 3, carbs: 18, fat: 3, fiber: 3),
        ]
        context.insert(breakfast)

        let lunch = FoodEntry(name: "Chicken quinoa bowl", mealType: .lunch, source: .aiPhoto, loggedAt: at(hour: 13))
        lunch.totalKcal = 540; lunch.protein = 42; lunch.carbs = 55; lunch.fat = 16; lunch.fiber = 9
        lunch.servingDesc = "1 plate"
        lunch.confidence = 0.88
        lunch.day = today
        context.insert(lunch)

        // Water
        for ml in [250, 250, 500] {
            context.insert(WaterLog(amountMl: ml, loggedAt: at(hour: Int.random(in: 8...16))))
        }

        // Weight history (last 10 days, gentle downward trend)
        for d in 0..<10 {
            let date = Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
            let w = 70.4 + Double(d) * 0.16
            context.insert(WeightEntry(weightKg: w, date: date))
        }

        // Streak
        let streak = Streak()
        streak.current = 5
        streak.longest = 12
        streak.lastLoggedDay = .now
        context.insert(streak)

        try? context.save()
    }

    private static func at(hour: Int) -> Date {
        Calendar.current.date(bySettingHour: max(0, min(23, hour)), minute: 0, second: 0, of: .now) ?? .now
    }
}
