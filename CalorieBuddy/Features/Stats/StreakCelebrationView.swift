//
//  StreakCelebrationView.swift
//  CalorieBuddy
//
//  Celebratory overlay shown when a logging streak advances.
//

import SwiftUI

struct StreakCelebrationView: View {
    let days: Int
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: Spacing.lg) {
                MascotView(mood: .fireStreak, size: 140)
                Text("🔥 \(days)-day streak!")
                    .font(CBFont.largeTitle)
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                Text("You're on a roll — keep it going!")
                    .font(CBFont.headline)
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)

                ShareLink(item: "I'm on a \(days)-day streak with CalorieBuddy! 🦊🔥") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(CBFont.headline)
                        .foregroundStyle(Theme.accent)
                }

                Button("Nice!", action: onDismiss)
                    .buttonStyle(.cbPrimary)
                    .padding(.horizontal, Spacing.lg)
            }
            .padding(Spacing.xl)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .cbShadow(.floating)
            .padding(.horizontal, Spacing.xl)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    StreakCelebrationView(days: 7, onDismiss: {})
}
