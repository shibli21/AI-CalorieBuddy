//
//  MascotView.swift
//  CalorieBuddy
//
//  The single render point for the CalorieBuddy mascot — "Pip", an original
//  friendly fox. Each mood maps to a `mascot-<rawValue>` image in the asset
//  catalog (generated via fal Ideogram transparent; see docs/BRAND.md).
//

import SwiftUI

enum MascotMood: String, CaseIterable {
    // Emotions
    case happy, excited, proud, sad, sleeping, hungry
    case love, wink, cool, surprised, thinking, crying, laughing, confused
    case determined, shy, angry, worried, celebrating, waving
    // Activities / contextual
    case drinkingWater = "drinking-water"
    case eatingSalad = "eating-salad"
    case running, weighing, meditating, scanning, cooking, trophy
    case fireStreak = "fire-streak"
    case strong, coffee, measuring, apple
    case noJunk = "no-junk"
    case thumbsUp = "thumbs-up"
    case pointing, calendar, target, stretching, phone

    var assetName: String { rawValue }
}

struct MascotView: View {
    var mood: MascotMood = .happy
    var size: CGFloat = 64

    var body: some View {
        Image("mascot-\(mood.assetName)")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel("Your buddy")
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(MascotMood.allCases, id: \.self) { mood in
                VStack {
                    MascotView(mood: mood, size: 72)
                    Text(mood.rawValue).font(.caption2)
                }
            }
        }
        .padding()
    }
    .background(Theme.background)
}
