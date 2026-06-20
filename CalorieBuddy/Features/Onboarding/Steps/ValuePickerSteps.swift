//
//  ValuePickerSteps.swift
//  CalorieBuddy
//
//  Body-metric and habit pickers for onboarding.
//

import SwiftUI

// MARK: - Age

struct AgeStep: View {
    @Binding var birthDate: Date
    var onContinue: () -> Void

    private var range: ClosedRange<Date> {
        let cal = Calendar.current
        let now = Date.now
        let lower = cal.date(byAdding: .year, value: -100, to: now) ?? now
        let upper = cal.date(byAdding: .year, value: -13, to: now) ?? now
        return lower...upper
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            StepHeader(title: "When were you born?",
                       subtitle: "Your age helps estimate your energy needs.")
                .padding(.horizontal, Spacing.screen)

            DatePicker("Birth date", selection: $birthDate, in: range, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Text("\(NutritionMath.age(from: birthDate)) years old")
                .font(CBFont.headline)
                .foregroundStyle(Theme.inkSecondary)

            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
    }
}

// MARK: - Height

struct HeightStep: View {
    @Binding var heightCm: Double
    var onContinue: () -> Void
    @State private var metric = true

    private var totalInches: Int { Int((heightCm / 2.54).rounded()) }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            StepHeader(title: "How tall are you?")
                .padding(.horizontal, Spacing.screen)

            Picker("Units", selection: $metric) {
                Text("cm").tag(true)
                Text("ft / in").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.screen)

            if metric {
                Picker("Height", selection: cmBinding) {
                    ForEach(120...220, id: \.self) { Text("\($0) cm").tag($0) }
                }
                .pickerStyle(.wheel)
            } else {
                HStack(spacing: 0) {
                    Picker("Feet", selection: feetBinding) {
                        ForEach(3...7, id: \.self) { Text("\($0) ft").tag($0) }
                    }
                    .pickerStyle(.wheel)
                    Picker("Inches", selection: inchBinding) {
                        ForEach(0...11, id: \.self) { Text("\($0) in").tag($0) }
                    }
                    .pickerStyle(.wheel)
                }
            }
            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
    }

    private var cmBinding: Binding<Int> {
        Binding(get: { Int(heightCm.rounded()) }, set: { heightCm = Double($0) })
    }
    private var feetBinding: Binding<Int> {
        Binding(get: { totalInches / 12 }, set: { heightCm = Double($0 * 12 + totalInches % 12) * 2.54 })
    }
    private var inchBinding: Binding<Int> {
        Binding(get: { totalInches % 12 }, set: { heightCm = Double((totalInches / 12) * 12 + $0) * 2.54 })
    }
}

// MARK: - Weight (reused for current + target)

struct WeightStep: View {
    let title: String
    var subtitle: String? = nil
    @Binding var weightKg: Double
    var onContinue: () -> Void
    @State private var metric = true

    private let kgValues: [Double] = Array(stride(from: 35.0, through: 200.0, by: 0.5))

    var body: some View {
        VStack(spacing: Spacing.lg) {
            StepHeader(title: title, subtitle: subtitle)
                .padding(.horizontal, Spacing.screen)

            Picker("Units", selection: $metric) {
                Text("kg").tag(true)
                Text("lb").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.screen)

            if metric {
                Picker("Weight", selection: kgBinding) {
                    ForEach(kgValues, id: \.self) { Text(kgLabel($0)).tag($0) }
                }
                .pickerStyle(.wheel)
            } else {
                Picker("Weight", selection: lbBinding) {
                    ForEach(77...440, id: \.self) { Text("\($0) lb").tag($0) }
                }
                .pickerStyle(.wheel)
            }
            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
    }

    private var kgBinding: Binding<Double> {
        Binding(get: { (weightKg * 2).rounded() / 2 }, set: { weightKg = $0 })
    }
    private var lbBinding: Binding<Int> {
        Binding(get: { Int((weightKg * 2.2046226).rounded()) }, set: { weightKg = Double($0) / 2.2046226 })
    }
    private func kgLabel(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v)) kg" : String(format: "%.1f kg", v)
    }
}

// MARK: - Meals per day

struct MealsPerDayStep: View {
    @Binding var meals: Int
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            StepHeader(title: "How many meals per day?",
                       subtitle: "Including snacks.")
                .padding(.horizontal, Spacing.screen)

            Picker("Meals", selection: $meals) {
                ForEach(1...6, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.screen)

            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
    }
}

// MARK: - Eating window

struct EatingWindowStep: View {
    @Binding var start: Int
    @Binding var end: Int
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            StepHeader(title: "Between what hours do you eat?",
                       subtitle: "We'll use this to suggest fasting windows.")
                .padding(.horizontal, Spacing.screen)

            HStack(spacing: 0) {
                VStack {
                    Text("From").font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                    Picker("From", selection: $start) {
                        ForEach(0...23, id: \.self) { Text(Self.hourLabel($0)).tag($0) }
                    }
                    .pickerStyle(.wheel)
                }
                VStack {
                    Text("To").font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                    Picker("To", selection: $end) {
                        ForEach(0...23, id: \.self) { Text(Self.hourLabel($0)).tag($0) }
                    }
                    .pickerStyle(.wheel)
                }
            }
            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
    }

    static func hourLabel(_ h: Int) -> String {
        let suffix = h < 12 ? "AM" : "PM"
        let display = h % 12 == 0 ? 12 : h % 12
        return "\(display) \(suffix)"
    }
}

// MARK: - Name your buddy

struct NamePetStep: View {
    @Binding var name: String
    var onContinue: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            MascotView(size: 96)
            Text("Name your buddy")
                .font(CBFont.title)
                .foregroundStyle(Theme.ink)
            Text("You can change this later in Settings.")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)

            TextField("Buddy", text: $name)
                .font(CBFont.title2)
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .focused($focused)
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.xl)
                .background(Theme.surfaceAlt, in: Capsule())
                .padding(.horizontal, Spacing.xl)
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomButton(disabled: name.trimmingCharacters(in: .whitespaces).isEmpty, action: onContinue)
        }
        .onAppear { focused = true }
    }
}

// MARK: - Reminder time

struct ReminderTimeStep: View {
    @Binding var enabled: Bool
    @Binding var hour: Int
    var onContinue: () -> Void
    @State private var time: Date = .now

    var body: some View {
        VStack(spacing: Spacing.lg) {
            StepHeader(title: "When should we remind you?",
                       subtitle: "A daily nudge to log your meals.")
                .padding(.horizontal, Spacing.screen)

            Toggle("Daily reminder", isOn: $enabled.animation(.smooth))
                .tint(Theme.accent)
                .padding(.horizontal, Spacing.screen)

            if enabled {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: time) { _, newValue in
                        hour = Calendar.current.component(.hour, from: newValue)
                    }
            }
            Spacer()
        }
        .padding(.top, Spacing.md)
        .safeAreaInset(edge: .bottom) { OnboardingBottomButton(action: onContinue) }
        .onAppear {
            time = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
        }
    }
}
