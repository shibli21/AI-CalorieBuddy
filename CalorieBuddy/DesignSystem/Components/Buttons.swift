//
//  Buttons.swift
//  CalorieBuddy
//
//  Shared button styles.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var fill: Color = Theme.accent
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CBFont.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(fill, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var tint: Color = Theme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CBFont.headline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.surfaceAlt, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var cbPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func cbPrimary(fill: Color) -> PrimaryButtonStyle { PrimaryButtonStyle(fill: fill) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var cbSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

/// A small circular icon button (back chevron, close, etc.).
struct CircleIconButton: View {
    let systemImage: String
    var size: CGFloat = 40
    var action: () -> Void

    var body: some View {
        Button(action: { Haptics.tap(); action() }) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: size, height: size)
                .background(Theme.surfaceAlt, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Get started") {}.buttonStyle(.cbPrimary)
        Button("Maybe later") {}.buttonStyle(.cbSecondary)
        CircleIconButton(systemImage: "chevron.left") {}
    }
    .padding()
    .background(Theme.background)
}
