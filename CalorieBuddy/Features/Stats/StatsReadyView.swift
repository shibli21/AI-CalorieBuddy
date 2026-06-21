//
//  StatsReadyView.swift
//  CalorieBuddy
//
//  One-time celebration shown when the user has logged enough days to unlock
//  their statistics (PLAN Phase 10 "stats-ready success").
//

import SwiftUI

struct StatsReadyView: View {
    var onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            MascotView(mood: .celebrating, size: 140)
            Text("Your stats are ready! 🎉")
                .font(CBFont.largeTitle)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
            Text("You've logged enough days to unlock your trends, charts, and streaks.")
                .font(CBFont.headline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button("See my stats") {
                onContinue()
                dismiss()
            }
            .buttonStyle(.cbPrimary)
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    StatsReadyView {}
}
