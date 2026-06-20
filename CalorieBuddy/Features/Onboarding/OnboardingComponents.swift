//
//  OnboardingComponents.swift
//  CalorieBuddy
//
//  Reusable building blocks for the onboarding flow: header chrome, choice and
//  info steps, and the pinned continue button.
//

import SwiftUI

struct OnboardingChrome: View {
    let progress: Double
    let canGoBack: Bool
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            if canGoBack {
                CircleIconButton(systemImage: "chevron.left", size: 36, action: onBack)
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
            ProgressView(value: min(1, max(0, progress)))
                .tint(Theme.accent)
                .animation(.smooth, value: progress)
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.vertical, Spacing.sm)
    }
}

struct StepHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(CBFont.title2)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OnboardingBottomButton: View {
    var title: String = "Continue"
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.cbPrimary)
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1)
            .padding(.horizontal, Spacing.screen)
            .padding(.vertical, Spacing.sm)
    }
}

struct ChoiceStep: View {
    let title: String
    var subtitle: String? = nil
    let options: [OBOption]
    var multiSelect: Bool = false
    @Binding var selected: Set<String>
    var continueTitle: String = "Continue"
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                StepHeader(title: title, subtitle: subtitle)
                    .padding(.bottom, Spacing.xs)
                ForEach(options) { opt in
                    OptionRow(
                        title: opt.title,
                        subtitle: opt.subtitle,
                        systemImage: opt.systemImage,
                        emoji: opt.emoji,
                        isSelected: selected.contains(opt.id),
                        multiSelect: multiSelect
                    ) { toggle(opt.id) }
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomButton(title: continueTitle, disabled: selected.isEmpty, action: onContinue)
        }
    }

    private func toggle(_ id: String) {
        if !multiSelect {
            selected = [id]
        } else if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }
}

struct InfoStep: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var emoji: String? = nil
    var bullets: [String] = []
    var continueTitle: String = "Continue"
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                if let emoji {
                    Text(emoji).font(.system(size: 68))
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundStyle(Theme.brandGradient)
                }
                Text(title)
                    .font(CBFont.title)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .font(CBFont.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !bullets.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        ForEach(bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accent)
                                Text(bullet)
                                    .font(CBFont.callout)
                                    .foregroundStyle(Theme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.sm)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            OnboardingBottomButton(title: continueTitle, action: onContinue)
        }
    }
}

#Preview("Choice") {
    ChoiceStep(
        title: "What's your main goal?",
        subtitle: "We'll tailor your plan around it.",
        options: [
            OBOption(id: "lose", title: "Lose weight", systemImage: "arrow.down.right"),
            OBOption(id: "maintain", title: "Maintain weight", systemImage: "equal"),
            OBOption(id: "gain", title: "Gain weight", systemImage: "arrow.up.right"),
        ],
        selected: .constant(["lose"]),
        onContinue: {}
    )
    .background(Theme.background)
}
