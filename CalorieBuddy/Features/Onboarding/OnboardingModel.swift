//
//  OnboardingModel.swift
//  CalorieBuddy
//
//  Draft answers + the page sequence + the view model that drives the flow.
//

import SwiftUI
import SwiftData
import Observation

/// A lightweight, identifiable option for choice steps.
struct OBOption: Identifiable, Hashable {
    var id: String
    var title: String
    var subtitle: String? = nil
    var emoji: String? = nil
    var systemImage: String? = nil
}

/// All collected answers before they're written to a UserProfile.
struct OnboardingDraft {
    var source: String = ""
    var goal: Goal = .lose
    var additionalGoals: Set<String> = []
    var experience: String = ""
    var sex: Sex = .female
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now
    var heightCm: Double = 168
    var currentWeightKg: Double = 70
    var targetWeightKg: Double = 63
    var activity: ActivityLevel = .moderate
    var pace: GoalPace = .steady
    var diet: DietType = .classic
    var restrictions: Set<String> = []
    var mealsPerDay: Int = 3
    var eatingWindowStart: Int = 8
    var eatingWindowEnd: Int = 20
    var eatingLocation: String = ""
    var habitGoals: Set<String> = []
    var remindersEnabled: Bool = false
    var reminderHour: Int = 19
    var mascotName: String = "Buddy"
    var interestedInFasting: Bool = true
}

enum OnboardingPage: Hashable {
    case welcome, carousel
    case source, goal, additionalGoals, experience, howItWorks
    case petIntro, petReveal, namePet
    case remindersIntro, reminderTime
    case eatingHabitsIntro, mealsPerDay, eatingWindow, eatingLocation, diet, restrictions
    case waterIntro, medicalDisclaimer, habitGoals, goalConfirmation
    case sex, age, activity, height, weight, summary
    case targetWeight, pace, realisticTarget
    case calculating, planReveal, rating, auth
}

/// Sanity check on the chosen target weight, so the `realisticTarget` step
/// reflects the actual input instead of always congratulating the user.
enum TargetAssessment: Equatable {
    case realistic
    case directionMismatch  // target contradicts the stated goal
    case tooLow             // target below a healthy BMI

    var mascot: MascotMood { self == .realistic ? .target : .worried }

    var title: String {
        switch self {
        case .realistic: "Your goal looks realistic"
        case .directionMismatch: "Let's double-check your target"
        case .tooLow: "Let's keep it healthy"
        }
    }

    var subtitle: String {
        switch self {
        case .realistic:
            "We'll keep your plan safe and sustainable."
        case .directionMismatch:
            "Your target weight points the opposite way to your goal. Tap back to adjust your goal or target."
        case .tooLow:
            "That target is below a healthy weight for your height. Consider a higher one — tap back to adjust."
        }
    }

    var continueTitle: String { self == .realistic ? "Continue" : "Continue anyway" }
}

@Observable
final class OnboardingViewModel {
    var draft = OnboardingDraft()
    var pageIndex = 0

    let pages: [OnboardingPage] = [
        .welcome, .carousel,
        .source, .goal, .additionalGoals, .experience, .howItWorks,
        .petIntro, .petReveal, .namePet,
        .remindersIntro, .reminderTime,
        .eatingHabitsIntro, .mealsPerDay, .eatingWindow, .eatingLocation, .diet, .restrictions,
        .waterIntro, .medicalDisclaimer, .habitGoals, .goalConfirmation,
        .sex, .age, .activity, .height, .weight, .targetWeight, .summary,
        .pace, .realisticTarget,
        .calculating, .planReveal, .rating, .auth,
    ]

    var current: OnboardingPage { pages[min(pageIndex, pages.count - 1)] }
    var isLast: Bool { pageIndex >= pages.count - 1 }

    /// Progress across the quiz portion (welcome/carousel excluded).
    var progress: Double {
        let total = max(1, pages.count - 2)
        let done = max(0, pageIndex - 1)
        return min(1, Double(done) / Double(total))
    }

    var showsChrome: Bool {
        switch current {
        case .welcome, .carousel, .calculating, .planReveal, .petReveal: false
        default: true
        }
    }

    func next() {
        Haptics.tap()
        if pageIndex < pages.count - 1 {
            pageIndex += 1
        }
    }

    func back() {
        Haptics.tap()
        if pageIndex > 0 { pageIndex -= 1 }
    }

    func go(to page: OnboardingPage) {
        if let idx = pages.firstIndex(of: page) { pageIndex = idx }
    }

    // MARK: - Plan preview (live, no persistence)

    var age: Int { NutritionMath.age(from: draft.birthDate) }

    var calorieTargetPreview: Int {
        let bmr = NutritionMath.bmr(sex: draft.sex, weightKg: draft.currentWeightKg, heightCm: draft.heightCm, age: age)
        let tdee = NutritionMath.tdee(bmr: bmr, activity: draft.activity)
        return NutritionMath.calorieTarget(tdee: tdee, goal: draft.goal, pace: draft.pace)
    }
    var macrosPreview: (p: Int, c: Int, f: Int) {
        NutritionMath.macros(calories: calorieTargetPreview, diet: draft.diet)
    }
    var waterPreview: Int {
        NutritionMath.waterGoalMl(weightKg: draft.currentWeightKg, activity: draft.activity)
    }
    var goalDate: Date {
        NutritionMath.projectedGoalDate(currentKg: draft.currentWeightKg, targetKg: draft.targetWeightKg, pace: draft.pace)
    }

    /// Validates the target weight against the stated goal and a healthy BMI floor.
    var targetAssessment: TargetAssessment {
        let delta = draft.targetWeightKg - draft.currentWeightKg
        let directionOK: Bool
        switch draft.goal {
        case .lose: directionOK = delta < 0
        case .gain: directionOK = delta > 0
        case .maintain: directionOK = abs(delta) <= 2
        }
        if !directionOK { return .directionMismatch }

        let targetBMI = NutritionMath.bmi(weightKg: draft.targetWeightKg, heightCm: draft.heightCm)
        if targetBMI < 18.5 { return .tooLow }
        return .realistic
    }

    // MARK: - Commit

    @MainActor
    func finish(context: ModelContext, existing: UserProfile?, notifications: NotificationService?) {
        let profile = existing ?? UserProfile()
        profile.sex = draft.sex
        profile.birthDate = draft.birthDate
        profile.heightCm = draft.heightCm
        profile.startWeightKg = draft.currentWeightKg
        profile.currentWeightKg = draft.currentWeightKg
        profile.targetWeightKg = draft.targetWeightKg
        profile.activityLevel = draft.activity
        profile.goal = draft.goal
        profile.goalPace = draft.pace
        profile.dietType = draft.diet
        profile.restrictions = Array(draft.restrictions)
        profile.fastingPresetHours = NutritionMath.fastingPreset(
            eatingStartHour: draft.eatingWindowStart, eatingEndHour: draft.eatingWindowEnd)
        profile.mascotName = draft.mascotName.isEmpty ? "Buddy" : draft.mascotName
        profile.remindersEnabled = draft.remindersEnabled
        profile.reminderHour = draft.reminderHour
        profile.recomputePlan()
        profile.onboardingCompleted = true

        if existing == nil { context.insert(profile) }

        // Seed a baseline weight entry.
        context.insert(WeightEntry(weightKg: draft.currentWeightKg, date: .now))
        // Seed the logging streak so the counter + celebration work from day one.
        DiaryStore.streak(in: context)
        try? context.save()

        if draft.remindersEnabled {
            notifications?.scheduleDailyReminder(hour: draft.reminderHour, mascotName: profile.mascotName)
        }
        Haptics.success()
    }
}
