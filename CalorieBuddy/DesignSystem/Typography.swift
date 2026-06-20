//
//  Typography.swift
//  CalorieBuddy
//
//  Rounded-design type scale. Relative styles scale with Dynamic Type; the
//  `display` helper is for hero numerals where a fixed size reads better.
//

import SwiftUI

enum CBFont {
    /// Fixed-size rounded font for hero numbers (calorie counts, timers).
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.bold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let bodyEmphasized = Font.system(.body, design: .rounded).weight(.semibold)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let caption2 = Font.system(.caption2, design: .rounded)
}

extension Text {
    /// Apply a CalorieBuddy font + the primary ink color in one call.
    func cbStyle(_ font: Font, color: Color = Theme.ink) -> Text {
        self.font(font).foregroundColor(color)
    }
}
