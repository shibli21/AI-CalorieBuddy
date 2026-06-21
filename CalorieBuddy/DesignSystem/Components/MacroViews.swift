//
//  MacroViews.swift
//  CalorieBuddy
//
//  Macro progress bars and chips.
//

import SwiftUI

struct MacroBar: View {
    let kind: MacroKind
    let value: Int
    let target: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progress: Double { target > 0 ? min(1, Double(value) / Double(target)) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle().fill(Theme.color(for: kind)).frame(width: 7, height: 7)
                Text(kind.title)
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceAlt)
                    Capsule()
                        .fill(Theme.color(for: kind))
                        .frame(width: max(0, geo.size.width * progress))
                        .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
            Text("\(value) / \(target) g")
                .font(CBFont.caption2)
                .foregroundStyle(Theme.ink)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.title)
        .accessibilityValue("\(value) of \(target) grams")
    }
}

struct MacroBars: View {
    let protein: Int
    let carbs: Int
    let fat: Int
    let proteinTarget: Int
    let carbsTarget: Int
    let fatTarget: Int

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            MacroBar(kind: .protein, value: protein, target: proteinTarget)
            MacroBar(kind: .carbs, value: carbs, target: carbsTarget)
            MacroBar(kind: .fat, value: fat, target: fatTarget)
        }
    }
}

/// Compact pill showing a single macro value (used in detail screens).
struct MacroChip: View {
    let kind: MacroKind
    let grams: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(grams)g")
                .font(CBFont.bodyEmphasized)
                .foregroundStyle(Theme.ink)
            Text(kind.title)
                .font(CBFont.caption2)
                .foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(Theme.color(for: kind).opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 24) {
        MacroBars(protein: 64, carbs: 120, fat: 38, proteinTarget: 140, carbsTarget: 200, fatTarget: 60)
        HStack(spacing: 8) {
            MacroChip(kind: .protein, grams: 64)
            MacroChip(kind: .carbs, grams: 120)
            MacroChip(kind: .fat, grams: 38)
        }
    }
    .padding()
    .background(Theme.background)
}
