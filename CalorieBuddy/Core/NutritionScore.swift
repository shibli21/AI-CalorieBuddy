//
//  NutritionScore.swift
//  CalorieBuddy
//
//  A simple, transparent nutrition-quality score (0–100) and the award badges
//  derived from a meal's macros.
//

import Foundation

enum NutritionScore {
    /// Score a single meal 0–100 from protein density, fiber, and macro balance.
    static func score(for entry: FoodEntry) -> Int {
        let kcal = Double(max(1, entry.totalKcal))
        let proteinPct = Double(entry.protein) * 4.0 / kcal
        let fatPct = Double(entry.fat) * 9.0 / kcal

        let proteinScore = min(1, proteinPct / 0.35)           // reward up to 35% protein
        let fiberScore = min(1, Double(entry.fiber) / 10.0)    // reward up to 10g fiber
        let fatPenalty = fatPct > 0.45 ? (fatPct - 0.45) : 0   // penalize very fatty meals

        let raw = 0.5 * proteinScore + 0.3 * fiberScore + 0.2 - fatPenalty
        return Int((max(0, min(1, raw)) * 100).rounded())
    }

    /// Score a day from total intake vs target and macro balance.
    static func dayScore(consumed: Int, target: Int, protein: Int, fiber: Int) -> Int {
        guard target > 0 else { return 0 }
        let ratio = Double(consumed) / Double(target)
        let calorieScore = 1 - min(1, abs(ratio - 0.95) / 0.6)      // best near target
        let proteinScore = min(1, Double(protein) / Double(max(1, target / 12)))
        let fiberScore = min(1, Double(fiber) / 25.0)
        let raw = 0.5 * calorieScore + 0.3 * proteinScore + 0.2 * fiberScore
        return Int((max(0, min(1, raw)) * 100).rounded())
    }

    static func grade(_ score: Int) -> String {
        switch score {
        case 80...: "Excellent"
        case 60..<80: "Good"
        case 40..<60: "Fair"
        default: "Could be better"
        }
    }
}

struct AwardPage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let systemImage: String
}

struct NutritionAward: Identifiable {
    let id: String
    let title: String
    let emoji: String
    let blurb: String
    let pages: [AwardPage]
}

enum Awards {
    static func awards(for entry: FoodEntry) -> [NutritionAward] {
        var result: [NutritionAward] = []
        let kcal = Double(max(1, entry.totalKcal))
        let proteinPct = Double(entry.protein) * 4.0 / kcal
        let carbPct = Double(entry.carbs) * 4.0 / kcal
        let fatPct = Double(entry.fat) * 9.0 / kcal

        if entry.fiber >= 6 { result.append(.fiber) }
        if proteinPct >= 0.30 { result.append(.highProtein) }
        if entry.totalKcal > 0 && entry.totalKcal <= 450 { result.append(.light) }
        if (0.2...0.4).contains(proteinPct) && (0.3...0.55).contains(carbPct) && (0.2...0.4).contains(fatPct) {
            result.append(.balanced)
        }
        return result
    }

    static let fiber = NutritionAward(
        id: "fiber", title: "Rich in fiber", emoji: "🌾",
        blurb: "This meal is a great source of dietary fiber.",
        pages: [
            AwardPage(title: "What is fiber?", body: "Fiber is the part of plant foods your body can't fully digest. It passes through your gut, doing good work along the way.", systemImage: "leaf.fill"),
            AwardPage(title: "Fiber & blood sugar", body: "Fiber slows how quickly sugar enters your blood, helping you avoid energy spikes and crashes.", systemImage: "waveform.path.ecg"),
            AwardPage(title: "Why it helps", body: "It keeps you full longer, supports healthy digestion, and feeds the good bacteria in your gut.", systemImage: "heart.fill"),
            AwardPage(title: "Great sources", body: "Beans, lentils, oats, berries, avocado, broccoli, and whole grains are all fiber-rich.", systemImage: "carrot.fill"),
            AwardPage(title: "Daily target", body: "Aim for about 25–30g of fiber per day. Small swaps add up quickly!", systemImage: "target"),
        ]
    )

    static let highProtein = NutritionAward(
        id: "protein", title: "High protein", emoji: "💪",
        blurb: "A protein-packed meal to support muscle and fullness.",
        pages: [
            AwardPage(title: "Why protein matters", body: "Protein builds and repairs muscle, and keeps you feeling full between meals.", systemImage: "figure.strengthtraining.traditional"),
            AwardPage(title: "Staying full", body: "Protein is the most satiating macro — high-protein meals help curb cravings.", systemImage: "fork.knife"),
            AwardPage(title: "Great sources", body: "Chicken, fish, eggs, Greek yogurt, tofu, beans, and lentils are protein-rich.", systemImage: "fish.fill"),
        ]
    )

    static let light = NutritionAward(
        id: "light", title: "Light meal", emoji: "🪶",
        blurb: "A lighter meal that leaves room in your budget.",
        pages: [
            AwardPage(title: "Light & balanced", body: "Lighter meals can help you stay within your calorie budget while still feeling satisfied.", systemImage: "leaf.fill"),
            AwardPage(title: "Make it filling", body: "Add veggies, protein, or fiber to a light meal to stay full for longer.", systemImage: "carrot.fill"),
        ]
    )

    static let balanced = NutritionAward(
        id: "balanced", title: "Well balanced", emoji: "⚖️",
        blurb: "A nicely balanced split of protein, carbs, and fat.",
        pages: [
            AwardPage(title: "Balanced macros", body: "This meal has a healthy mix of protein, carbs, and fat — great for steady energy.", systemImage: "scalemass.fill"),
            AwardPage(title: "Why balance helps", body: "Balanced meals support stable energy, recovery, and lasting fullness.", systemImage: "bolt.heart.fill"),
        ]
    )
}
