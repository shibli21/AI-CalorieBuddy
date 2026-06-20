//
//  Controls.swift
//  CalorieBuddy
//
//  Selection controls used throughout onboarding and settings.
//

import SwiftUI

struct Chip: View {
    let title: String
    var systemImage: String? = nil
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 6) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(CBFont.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? .white : Theme.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Theme.accent : Theme.surfaceAlt, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct PageDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(0, count), id: \.self) { i in
                Capsule()
                    .fill(i == index ? Theme.accent : Theme.separator)
                    .frame(width: i == index ? 22 : 7, height: 7)
                    .animation(.snappy, value: index)
            }
        }
    }
}

/// A large tappable option row with leading icon, title/subtitle, and a
/// selection indicator. Used for single- and multi-select onboarding steps.
struct OptionRow: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var emoji: String? = nil
    var isSelected: Bool
    var multiSelect: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: Spacing.md) {
                if let emoji {
                    Text(emoji).font(.title2).frame(width: 30)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(isSelected ? Theme.accent : Theme.inkSecondary)
                        .frame(width: 30)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CBFont.bodyEmphasized)
                        .foregroundStyle(Theme.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(CBFont.caption)
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                Spacer(minLength: Spacing.sm)
                Image(systemName: indicatorImage)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Theme.accent : Theme.separator)
            }
            .padding(Spacing.lg)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? Theme.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var indicatorImage: String {
        if multiSelect {
            return isSelected ? "checkmark.square.fill" : "square"
        }
        return isSelected ? "checkmark.circle.fill" : "circle"
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack {
            Chip(title: "Vegan", systemImage: "leaf.fill", isSelected: true) {}
            Chip(title: "Keto", isSelected: false) {}
        }
        PageDots(count: 5, index: 2)
        OptionRow(title: "Lose weight", subtitle: "Build a calorie deficit", systemImage: "arrow.down.right", isSelected: true) {}
        OptionRow(title: "Maintain", systemImage: "equal", isSelected: false) {}
    }
    .padding()
    .background(Theme.background)
}
