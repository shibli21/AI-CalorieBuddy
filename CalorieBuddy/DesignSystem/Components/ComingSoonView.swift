//
//  ComingSoonView.swift
//  CalorieBuddy
//
//  Temporary placeholder for screens not yet built. Replaced phase by phase.
//

import SwiftUI

struct ComingSoonView: View {
    let title: String
    var systemImage: String = "hammer.fill"
    var note: String = "Coming together…"

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: Spacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                    Text(title)
                        .font(CBFont.title2)
                        .foregroundStyle(Theme.ink)
                    Text(note)
                        .font(CBFont.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ComingSoonView(title: "Today", systemImage: "house.fill")
}
