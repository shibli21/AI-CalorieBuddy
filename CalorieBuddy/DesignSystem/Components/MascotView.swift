//
//  MascotView.swift
//  CalorieBuddy
//
//  The single render point for the CalorieBuddy mascot — "Pip", an original
//  friendly fox. Currently renders an emoji placeholder; when illustrated
//  artwork is added to the asset catalog (mascot-happy, mascot-sleeping, …)
//  swap the body to `Image("mascot-\(mood.assetName)")`. See docs/BRAND.md.
//

import SwiftUI

enum MascotMood: String {
    case happy, excited, sleeping, sad, proud, hungry

    var emoji: String {
        switch self {
        case .happy: "🦊"
        case .excited: "🤩"
        case .sleeping: "😴"
        case .sad: "🙈"
        case .proud: "😎"
        case .hungry: "😋"
        }
    }

    var assetName: String { rawValue }
}

struct MascotView: View {
    var mood: MascotMood = .happy
    var size: CGFloat = 64

    var body: some View {
        // Placeholder rendering. Replace with illustrated assets when available:
        //   Image(mood.assetName).resizable().scaledToFit().frame(width: size, height: size)
        Text(mood.emoji)
            .font(.system(size: size))
            .accessibilityLabel("Your buddy")
    }
}

#Preview {
    HStack(spacing: 16) {
        MascotView(mood: .happy)
        MascotView(mood: .excited)
        MascotView(mood: .sleeping)
        MascotView(mood: .proud)
    }
    .padding()
    .background(Theme.background)
}
