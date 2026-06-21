//
//  OnboardingSpecialViews.swift
//  CalorieBuddy
//
//  Plan calculation, plan reveal, and account creation steps.
//

import SwiftUI
import AuthenticationServices

// MARK: - Calculating

struct PlanCalculatingView: View {
    var onFinish: () -> Void
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            MascotView(mood: .excited, size: 92)
            ZStack {
                ProgressRing(progress: progress, lineWidth: 16)
                    .frame(width: 168, height: 168)
                Text("\(Int(progress * 100))%")
                    .font(CBFont.display(34))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            VStack(spacing: Spacing.xs) {
                Text("Building your plan…")
                    .font(CBFont.title2)
                    .foregroundStyle(Theme.ink)
                Text(caption)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
                    .contentTransition(.opacity)
            }
            Spacer()
        }
        .task {
            for tick in stride(from: 0.0, through: 1.0, by: 0.02) {
                progress = tick
                try? await Task.sleep(for: .seconds(0.045))
            }
            Haptics.success()
            try? await Task.sleep(for: .seconds(0.35))
            onFinish()
        }
    }

    private var caption: String {
        switch progress {
        case ..<0.35: "Analyzing your goals"
        case ..<0.7: "Calculating your targets"
        default: "Almost there"
        }
    }
}

// MARK: - Plan reveal

struct PlanRevealView: View {
    let calories: Int
    let macros: (p: Int, c: Int, f: Int)
    let waterMl: Int
    let goalDate: Date
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                VStack(spacing: Spacing.xs) {
                    MascotView(mood: .proud, size: 110)
                    Text("Your plan is ready!")
                        .font(CBFont.largeTitle)
                        .foregroundStyle(Theme.ink)
                    Text("Personalized just for you")
                        .font(CBFont.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
                .padding(.top, Spacing.lg)

                VStack(spacing: Spacing.xs) {
                    Text("Daily calories")
                        .font(CBFont.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                    Text("\(calories)")
                        .font(CBFont.display(50))
                        .foregroundStyle(Theme.ink)
                    Text("kcal")
                        .font(CBFont.caption)
                        .foregroundStyle(Theme.inkSecondary)
                }
                .frame(maxWidth: .infinity)
                .cbCard()

                HStack(spacing: Spacing.sm) {
                    MacroChip(kind: .protein, grams: macros.p)
                    MacroChip(kind: .carbs, grams: macros.c)
                    MacroChip(kind: .fat, grams: macros.f)
                }

                HStack(spacing: Spacing.md) {
                    statCard(icon: "drop.fill", tint: Theme.water,
                             value: "\(waterMl) ml", label: "Water goal")
                    statCard(icon: "flag.checkered", tint: Theme.accent,
                             value: goalDate.formatted(.dateTime.month().day()), label: "Goal date")
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomButton(title: "Looks great", action: onContinue)
        }
    }

    private func statCard(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon).font(.title2).foregroundStyle(tint)
            Text(value).font(CBFont.headline).foregroundStyle(Theme.ink)
            Text(label).font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .cbCard()
    }
}

// MARK: - Account

struct OnboardingAuthView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "icloud.fill")
                .font(.system(size: 62))
                .foregroundStyle(Theme.brandGradient)
            Text("Save your progress")
                .font(CBFont.largeTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
            Text("Create an account to back up and sync across your devices.")
                .font(CBFont.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.inkSecondary)
                .padding(.horizontal, Spacing.xl)
            Spacer()

            VStack(spacing: Spacing.md) {
                SignInWithAppleButton(.signUp) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { _ in
                    // Identity is the iCloud account for sync; we proceed either way.
                    Haptics.success()
                    onContinue()
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(Capsule())

                Button("Continue without an account", action: onContinue)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.xl)
        }
    }
}

#Preview("Reveal") {
    PlanRevealView(calories: 1840, macros: (138, 184, 61), waterMl: 2600,
                   goalDate: .now.addingTimeInterval(60 * 86400), onContinue: {})
}
