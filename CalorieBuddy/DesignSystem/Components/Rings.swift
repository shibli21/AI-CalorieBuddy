//
//  Rings.swift
//  CalorieBuddy
//
//  Circular progress indicators: a generic ProgressRing and the dashboard
//  CalorieRing hero.
//

import SwiftUI

struct ProgressRing: View {
    var progress: Double                 // 0...1 (clamped for drawing)
    var lineWidth: CGFloat = 14
    var colors: [Color] = [Theme.accent, Theme.accentDeep]
    var track: Color = Theme.surfaceAlt
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: min(1, max(0.0001, progress)))
                .stroke(
                    AngularGradient(colors: colors, center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .smooth(duration: 0.6), value: progress)
        }
    }
}

struct CalorieRing: View {
    var consumed: Int
    var target: Int
    var mode: CaloriesDisplayMode = .remaining

    private var progress: Double { target > 0 ? Double(consumed) / Double(target) : 0 }
    private var remaining: Int { target - consumed }

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, lineWidth: 18, colors: ringColors)
            VStack(spacing: 2) {
                Text("\(displayValue)")
                    .font(CBFont.display(42))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
                    .monospacedDigit()
                Text(displayLabel)
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityName)
        .accessibilityValue("\(displayValue) of \(target) kilocalories")
    }

    private var accessibilityName: String {
        if mode == .consumed { return "Calories eaten" }
        return remaining >= 0 ? "Calories remaining" : "Calories over budget"
    }

    private var displayValue: Int {
        mode == .remaining ? max(0, remaining) : consumed
    }
    private var displayLabel: String {
        if mode == .consumed { return "kcal eaten" }
        return remaining >= 0 ? "kcal left" : "kcal over"
    }
    private var ringColors: [Color] {
        progress > 1 ? [Theme.amber, Theme.berry] : [Theme.accent, Theme.accentDeep]
    }
}

#Preview {
    HStack(spacing: 24) {
        CalorieRing(consumed: 850, target: 1800)
            .frame(width: 160, height: 160)
        CalorieRing(consumed: 2050, target: 1800)
            .frame(width: 160, height: 160)
    }
    .padding()
    .background(Theme.background)
}
