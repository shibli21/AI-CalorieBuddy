//
//  OnboardingWelcomeView.swift
//  CalorieBuddy
//
//  First screen: value proposition + start.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    var onStart: () -> Void

    var body: some View {
        ZStack {
            Theme.warmBackground.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                VStack(spacing: Spacing.lg) {
                    MascotView(mood: .happy, size: 150)
                        .cbShadow(.subtle)

                    Text("Reach your\nweight goals")
                        .font(CBFont.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.ink)

                    Text("Snap a photo and let AI do the rest —\nwith your CalorieBuddy.")
                        .font(CBFont.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.inkSecondary)
                }

                Spacer()

                VStack(spacing: Spacing.md) {
                    Button("Get started", action: onStart)
                        .buttonStyle(.cbPrimary)
                    Text("By continuing you accept our Terms of Use and Privacy Notice.")
                        .font(CBFont.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.inkTertiary)
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

#Preview {
    OnboardingWelcomeView(onStart: {})
}
