//
//  SettingsEditViews.swift
//  CalorieBuddy
//
//  Editors for the plan, personal details, and eating preferences.
//

import SwiftUI
import SwiftData

struct EditPlanView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    var body: some View {
        Form {
            Section("Daily calories") {
                Stepper(value: $profile.calorieTarget, in: 1000...5000, step: 10) {
                    HStack {
                        Text("Target")
                        Spacer()
                        Text("\(profile.calorieTarget) kcal").foregroundStyle(.secondary)
                    }
                }
            }
            Section("Macros (grams)") {
                macroStepper("Protein", value: $profile.proteinTargetG, tint: Theme.berry)
                macroStepper("Carbs", value: $profile.carbTargetG, tint: Theme.amber)
                macroStepper("Fat", value: $profile.fatTargetG, tint: Theme.sky)
            }
            Section {
                Button {
                    profile.recomputePlan()
                    try? context.save()
                    Haptics.success()
                } label: {
                    Label("Recalculate from my details", systemImage: "arrow.clockwise")
                }
            } footer: {
                Text("Recomputes your targets from your body metrics and goal.")
            }
        }
        .navigationTitle("Calories & macros")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { try? context.save() }
    }

    private func macroStepper(_ label: String, value: Binding<Int>, tint: Color) -> some View {
        Stepper(value: value, in: 0...400, step: 5) {
            HStack {
                Circle().fill(tint).frame(width: 8, height: 8)
                Text(label)
                Spacer()
                Text("\(value.wrappedValue) g").foregroundStyle(.secondary)
            }
        }
    }
}

struct PersonalDetailsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    private var birthRange: ClosedRange<Date> {
        let cal = Calendar.current
        let now = Date.now
        let lower = cal.date(byAdding: .year, value: -100, to: now) ?? now
        let upper = cal.date(byAdding: .year, value: -13, to: now) ?? now
        return lower...upper
    }

    var body: some View {
        Form {
            Section("About you") {
                Picker("Sex", selection: $profile.sex) {
                    ForEach(Sex.allCases) { Text($0.title).tag($0) }
                }
                DatePicker("Birth date", selection: $profile.birthDate, in: birthRange, displayedComponents: .date)
                Stepper(value: $profile.heightCm, in: 120...220, step: 1) {
                    HStack { Text("Height"); Spacer(); Text("\(Int(profile.heightCm)) cm").foregroundStyle(.secondary) }
                }
            }
            Section("Weight") {
                Stepper(value: $profile.currentWeightKg, in: 30...250, step: 0.5) {
                    HStack { Text("Current"); Spacer(); Text(String(format: "%.1f kg", profile.currentWeightKg)).foregroundStyle(.secondary) }
                }
                Stepper(value: $profile.targetWeightKg, in: 30...250, step: 0.5) {
                    HStack { Text("Target"); Spacer(); Text(String(format: "%.1f kg", profile.targetWeightKg)).foregroundStyle(.secondary) }
                }
            }
            Section("Goal") {
                Picker("Goal", selection: $profile.goal) {
                    ForEach(Goal.allCases) { Text($0.title).tag($0) }
                }
                Picker("Activity", selection: $profile.activityLevel) {
                    ForEach(ActivityLevel.allCases) { Text($0.title).tag($0) }
                }
                Picker("Pace", selection: $profile.goalPace) {
                    ForEach(GoalPace.allCases) { Text($0.title).tag($0) }
                }
            }
        }
        .navigationTitle("Personal details")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            profile.recomputePlan()
            try? context.save()
        }
    }
}

struct EatingPrefsView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context
    @State private var restrictions: Set<String> = []

    var body: some View {
        Form {
            Section("Diet") {
                Picker("Diet type", selection: $profile.dietType) {
                    ForEach(DietType.allCases) { Text($0.title).tag($0) }
                }
            }
            Section("Restrictions & allergies") {
                ForEach(OnboardingFlow.restrictionOptions) { option in
                    Button {
                        toggle(option.id)
                    } label: {
                        HStack {
                            Text(option.emoji ?? "")
                            Text(option.title).foregroundStyle(Theme.ink)
                            Spacer()
                            if restrictions.contains(option.id) {
                                Image(systemName: "checkmark").foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Eating preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { restrictions = Set(profile.restrictions) }
        .onDisappear {
            profile.restrictions = Array(restrictions)
            profile.recomputePlan()
            try? context.save()
        }
    }

    private func toggle(_ id: String) {
        Haptics.selection()
        if restrictions.contains(id) { restrictions.remove(id) } else { restrictions.insert(id) }
    }
}
