//
//  OnboardingFlow.swift
//  CalorieBuddy
//
//  Coordinator for the onboarding funnel. Renders the current page, manages the
//  progress chrome, and commits the profile at the end.
//

import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var context
    @Environment(NotificationService.self) private var notifications
    @Environment(\.requestReview) private var requestReview
    @Query private var profiles: [UserProfile]
    @State private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if vm.showsChrome {
                    OnboardingChrome(progress: vm.progress, canGoBack: vm.pageIndex > 0) { vm.back() }
                }

                content(vm: vm)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(vm.pageIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.smooth(duration: 0.35), value: vm.pageIndex)
    }

    // MARK: - Page routing

    @ViewBuilder
    private func content(vm: OnboardingViewModel) -> some View {
        @Bindable var vm = vm
        let proceed: () -> Void = {
            if vm.isLast { finishFlow(vm) } else { vm.next() }
        }

        switch vm.current {
        case .welcome:
            OnboardingWelcomeView { vm.next() }

        case .carousel:
            OnboardingCarouselView { vm.next() }

        case .source:
            ChoiceStep(title: "How did you hear about us?",
                       options: Self.sourceOptions,
                       selected: single(get: { vm.draft.source }, set: { vm.draft.source = $0 }),
                       onContinue: proceed)

        case .goal:
            ChoiceStep(title: "What's your main goal?",
                       subtitle: "We'll tailor your plan around it.",
                       options: Goal.allCases.map { OBOption(id: $0.rawValue, title: $0.title, systemImage: $0.systemImage) },
                       selected: enumSingle(get: { vm.draft.goal.rawValue }, set: { if let g = Goal(rawValue: $0) { vm.draft.goal = g } }),
                       onContinue: proceed)

        case .additionalGoals:
            ChoiceStep(title: "Any additional goals?",
                       subtitle: "Pick all that apply.",
                       options: Self.additionalGoalOptions,
                       multiSelect: true,
                       selected: $vm.draft.additionalGoals,
                       onContinue: proceed)

        case .experience:
            ChoiceStep(title: "Have you counted calories before?",
                       options: Self.experienceOptions,
                       selected: single(get: { vm.draft.experience }, set: { vm.draft.experience = $0 }),
                       onContinue: proceed)

        case .howItWorks:
            InfoStep(title: "How CalorieBuddy works",
                     mascot: .scanning,
                     bullets: ["Snap a photo of your meal",
                               "AI estimates calories & macros",
                               "Review and log in seconds",
                               "Track water, fasting & weight",
                               "Watch your trend reach your goal"],
                     onContinue: proceed)

        case .petIntro:
            InfoStep(title: "Meet your buddy",
                     subtitle: "A friendly companion to keep you logging every day.",
                     mascot: .happy,
                     onContinue: proceed)

        case .petReveal:
            InfoStep(title: "Say hi to your buddy!",
                     subtitle: "Keep your streak alive and watch them thrive.",
                     mascot: .excited,
                     continueTitle: "Aww, hi!",
                     onContinue: proceed)

        case .namePet:
            NamePetStep(name: $vm.draft.mascotName, onContinue: proceed)

        case .remindersIntro:
            InfoStep(title: "We'll help you stay on track",
                     subtitle: "A gentle daily nudge keeps your streak going.",
                     mascot: .calendar,
                     onContinue: proceed)

        case .reminderTime:
            ReminderTimeStep(enabled: $vm.draft.remindersEnabled, hour: $vm.draft.reminderHour) {
                if vm.draft.remindersEnabled {
                    Task { _ = await notifications.requestAuthorization(); proceed() }
                } else {
                    proceed()
                }
            }

        case .eatingHabitsIntro:
            InfoStep(title: "Let's talk about your eating habits",
                     subtitle: "This helps us personalize your plan.",
                     mascot: .eatingSalad,
                     onContinue: proceed)

        case .mealsPerDay:
            MealsPerDayStep(meals: $vm.draft.mealsPerDay, onContinue: proceed)

        case .eatingWindow:
            EatingWindowStep(start: $vm.draft.eatingWindowStart, end: $vm.draft.eatingWindowEnd, onContinue: proceed)

        case .eatingLocation:
            ChoiceStep(title: "Where do you usually eat?",
                       options: Self.locationOptions,
                       selected: single(get: { vm.draft.eatingLocation }, set: { vm.draft.eatingLocation = $0 }),
                       onContinue: proceed)

        case .diet:
            ChoiceStep(title: "What type of diet do you prefer?",
                       options: DietType.allCases.map { OBOption(id: $0.rawValue, title: $0.title, emoji: $0.emoji) },
                       selected: enumSingle(get: { vm.draft.diet.rawValue }, set: { if let d = DietType(rawValue: $0) { vm.draft.diet = d } }),
                       onContinue: proceed)

        case .restrictions:
            ChoiceStep(title: "Any food restrictions or allergies?",
                       subtitle: "Pick all that apply.",
                       options: Self.restrictionOptions,
                       multiSelect: true,
                       selected: $vm.draft.restrictions,
                       onContinue: proceed)

        case .waterIntro:
            InfoStep(title: "Hydration matters",
                     subtitle: "Staying hydrated supports energy, focus, and appetite control.",
                     mascot: .drinkingWater,
                     bullets: ["Boosts metabolism", "Curbs false hunger", "Improves focus"],
                     onContinue: proceed)

        case .medicalDisclaimer:
            InfoStep(title: "A quick note",
                     subtitle: "CalorieBuddy provides estimates for general wellness and isn't medical advice. Consult a professional for medical guidance.",
                     systemImage: "cross.case.fill",
                     continueTitle: "I understand",
                     onContinue: proceed)

        case .habitGoals:
            ChoiceStep(title: "What habits do you want to build?",
                       subtitle: "Pick all that apply.",
                       options: Self.habitOptions,
                       multiSelect: true,
                       selected: $vm.draft.habitGoals,
                       onContinue: proceed)

        case .goalConfirmation:
            InfoStep(title: "Great choice!",
                     subtitle: "You're all set up for success. Let's get your numbers.",
                     mascot: .celebrating,
                     onContinue: proceed)

        case .sex:
            ChoiceStep(title: "What's your biological sex?",
                       subtitle: "Used to calculate your energy needs.",
                       options: Sex.allCases.map { OBOption(id: $0.rawValue, title: $0.title) },
                       selected: enumSingle(get: { vm.draft.sex.rawValue }, set: { if let s = Sex(rawValue: $0) { vm.draft.sex = s } }),
                       onContinue: proceed)

        case .age:
            AgeStep(birthDate: $vm.draft.birthDate, onContinue: proceed)

        case .activity:
            ChoiceStep(title: "How active are you?",
                       options: ActivityLevel.allCases.map { OBOption(id: $0.rawValue, title: $0.title, subtitle: $0.subtitle, systemImage: $0.systemImage) },
                       selected: enumSingle(get: { vm.draft.activity.rawValue }, set: { if let a = ActivityLevel(rawValue: $0) { vm.draft.activity = a } }),
                       onContinue: proceed)

        case .height:
            HeightStep(heightCm: $vm.draft.heightCm, onContinue: proceed)

        case .weight:
            WeightStep(title: "What's your current weight?", weightKg: $vm.draft.currentWeightKg, onContinue: proceed)

        case .summary:
            InfoStep(title: "Here's your profile",
                     subtitle: "BMI \(String(format: "%.1f", NutritionMath.bmi(weightKg: vm.draft.currentWeightKg, heightCm: vm.draft.heightCm))) · \(NutritionMath.bmiCategory(NutritionMath.bmi(weightKg: vm.draft.currentWeightKg, heightCm: vm.draft.heightCm)))\nAge \(vm.age) · \(Int(vm.draft.currentWeightKg)) kg → \(Int(vm.draft.targetWeightKg)) kg",
                     mascot: .happy,
                     onContinue: proceed)

        case .targetWeight:
            WeightStep(title: "What's your target weight?", weightKg: $vm.draft.targetWeightKg, onContinue: proceed)

        case .pace:
            ChoiceStep(title: "How fast do you want to go?",
                       subtitle: "We keep it safe and sustainable.",
                       options: GoalPace.allCases.map { OBOption(id: $0.rawValue, title: $0.title, subtitle: String(format: "%.2g kg / week", $0.kgPerWeek)) },
                       selected: enumSingle(get: { vm.draft.pace.rawValue }, set: { if let p = GoalPace(rawValue: $0) { vm.draft.pace = p } }),
                       onContinue: proceed)

        case .realisticTarget:
            InfoStep(title: "Your goal looks realistic",
                     subtitle: "We'll keep your plan safe and sustainable.",
                     mascot: .target,
                     onContinue: proceed)

        case .calculating:
            PlanCalculatingView(onFinish: proceed)

        case .planReveal:
            PlanRevealView(calories: vm.calorieTargetPreview,
                           macros: vm.macrosPreview,
                           waterMl: vm.waterPreview,
                           goalDate: vm.goalDate,
                           onContinue: proceed)

        case .rating:
            InfoStep(title: "Enjoying CalorieBuddy so far?",
                     subtitle: "A rating helps other people find us.",
                     systemImage: "star.fill",
                     continueTitle: "Continue") {
                requestReview()
                proceed()
            }

        case .auth:
            OnboardingAuthView(onContinue: proceed)
        }
    }

    // MARK: - Helpers

    /// Binding for a single string-valued draft field, as a one-element set.
    private func single(get: @escaping () -> String, set: @escaping (String) -> Void) -> Binding<Set<String>> {
        Binding(get: { get().isEmpty ? [] : [get()] }, set: { set($0.first ?? "") })
    }

    /// Binding for an enum-backed draft field stored by raw value.
    private func enumSingle(get: @escaping () -> String, set: @escaping (String) -> Void) -> Binding<Set<String>> {
        Binding(get: { [get()] }, set: { if let v = $0.first { set(v) } })
    }

    private func finishFlow(_ vm: OnboardingViewModel) {
        vm.finish(context: context, existing: profiles.first, notifications: notifications)
    }

    // MARK: - Option data

    static let sourceOptions = [
        OBOption(id: "appstore", title: "App Store", systemImage: "apple.logo"),
        OBOption(id: "instagram", title: "Instagram", systemImage: "camera.fill"),
        OBOption(id: "tiktok", title: "TikTok", systemImage: "music.note"),
        OBOption(id: "friend", title: "Friend or family", systemImage: "person.2.fill"),
        OBOption(id: "web", title: "Web search", systemImage: "magnifyingglass"),
        OBOption(id: "other", title: "Other", systemImage: "ellipsis"),
    ]

    static let experienceOptions = [
        OBOption(id: "never", title: "Never tried", subtitle: "I'm new to this"),
        OBOption(id: "some", title: "A little", subtitle: "On and off"),
        OBOption(id: "experienced", title: "Experienced", subtitle: "I know my macros"),
    ]

    static let additionalGoalOptions = [
        OBOption(id: "energy", title: "More energy", emoji: "⚡️"),
        OBOption(id: "muscle", title: "Build muscle", emoji: "💪"),
        OBOption(id: "habits", title: "Healthier habits", emoji: "🌱"),
        OBOption(id: "sleep", title: "Better sleep", emoji: "😴"),
        OBOption(id: "confidence", title: "Feel confident", emoji: "✨"),
    ]

    static let locationOptions = [
        OBOption(id: "home", title: "At home", emoji: "🏠"),
        OBOption(id: "work", title: "At work", emoji: "💼"),
        OBOption(id: "out", title: "Eating out", emoji: "🍽️"),
        OBOption(id: "mixed", title: "A mix", emoji: "🔀"),
    ]

    static let restrictionOptions = [
        OBOption(id: "none", title: "None", emoji: "✅"),
        OBOption(id: "gluten", title: "Gluten-free", emoji: "🌾"),
        OBOption(id: "dairy", title: "Dairy-free", emoji: "🥛"),
        OBOption(id: "nuts", title: "Nut allergy", emoji: "🥜"),
        OBOption(id: "shellfish", title: "Shellfish", emoji: "🦐"),
        OBOption(id: "eggs", title: "Eggs", emoji: "🥚"),
        OBOption(id: "soy", title: "Soy", emoji: "🫘"),
    ]

    static let habitOptions = [
        OBOption(id: "log", title: "Log every meal", emoji: "📓"),
        OBOption(id: "water", title: "Drink more water", emoji: "💧"),
        OBOption(id: "protein", title: "Hit protein goals", emoji: "🍗"),
        OBOption(id: "fasting", title: "Try fasting", emoji: "⏱️"),
        OBOption(id: "veggies", title: "Eat more veggies", emoji: "🥦"),
    ]
}

#Preview {
    OnboardingFlow()
        .environment(NotificationService())
        .modelContainer(AppContainer.make(inMemory: true))
}
