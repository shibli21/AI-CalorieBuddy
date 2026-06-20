//
//  Cards.swift
//  CalorieBuddy
//
//  Surface containers. GlassPanel currently uses a Material; it gets upgraded
//  to a true `.glassEffect` in the Liquid Glass polish pass (task #19), which
//  must be validated on device.
//

import SwiftUI

struct CardBackground: ViewModifier {
    var cornerRadius: CGFloat = Radius.lg
    var padding: CGFloat = Spacing.lg
    var fill: Color = Theme.surface

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(fill, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .cbShadow(.card)
    }
}

extension View {
    func cbCard(cornerRadius: CGFloat = Radius.lg,
                padding: CGFloat = Spacing.lg,
                fill: Color = Theme.surface) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius, padding: padding, fill: fill))
    }
}

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = Radius.lg
    var padding: CGFloat = Spacing.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

struct SectionHeader: View {
    let title: String
    var actionLabel: String = "See all"
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(CBFont.title3)
                .foregroundStyle(Theme.ink)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.accent)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        VStack(alignment: .leading) {
            SectionHeader(title: "Today", action: {})
            Text("Card content").foregroundStyle(Theme.inkSecondary)
        }
        .cbCard()

        GlassPanel {
            Text("Glass content").foregroundStyle(Theme.ink)
        }
    }
    .padding()
    .background(Theme.background)
}
