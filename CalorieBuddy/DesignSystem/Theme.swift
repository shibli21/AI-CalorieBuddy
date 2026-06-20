//
//  Theme.swift
//  CalorieBuddy
//
//  Central color tokens for the CalorieBuddy brand. Original palette — friendly,
//  warm, health-forward — designed to sit well on iOS 26 Liquid Glass surfaces.
//

import SwiftUI

enum MacroKind: String, CaseIterable, Identifiable {
    case protein, carbs, fat
    var id: String { rawValue }
    var title: String {
        switch self {
        case .protein: "Protein"
        case .carbs: "Carbs"
        case .fat: "Fat"
        }
    }
    var short: String {
        switch self {
        case .protein: "P"
        case .carbs: "C"
        case .fat: "F"
        }
    }
}

enum Theme {
    // MARK: Brand palette
    static let accent = Color(hex: 0x2FBF71)       // sprout green — primary
    static let accentDeep = Color(hex: 0x1E9E59)
    static let accentSoft = Color(light: 0xDFF5E9, dark: 0x123A28)

    static let berry = Color(hex: 0xFF5A7E)        // protein
    static let amber = Color(hex: 0xFFB23E)        // carbs
    static let sky = Color(hex: 0x4DA8FF)          // fat
    static let grape = Color(hex: 0x8B7CF6)        // fasting / accent 2
    static let water = Color(hex: 0x33B6E6)        // hydration

    // MARK: Text
    static let ink = Color(light: 0x14141A, dark: 0xF5F5F7)
    static let inkSecondary = Color(light: 0x6B6B76, dark: 0xAEAEB6)
    static let inkTertiary = Color(light: 0x9A9AA3, dark: 0x7C7C86)

    // MARK: Surfaces (adaptive)
    static let background = Color(light: 0xFBF8F3, dark: 0x0D0D11)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1A1A21)
    static let surfaceAlt = Color(light: 0xF3EFE7, dark: 0x23232B)
    static let separator = Color(light: 0xEAE4DA, dark: 0x2C2C35)

    // MARK: Macro colors
    static func color(for macro: MacroKind) -> Color {
        switch macro {
        case .protein: berry
        case .carbs: amber
        case .fat: sky
        }
    }

    // MARK: Gradients
    static var brandGradient: LinearGradient {
        LinearGradient(colors: [accent, accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var warmBackground: LinearGradient {
        LinearGradient(
            colors: [Color(light: 0xFFF3E6, dark: 0x16131B), Color(light: 0xFBF8F3, dark: 0x0D0D11)],
            startPoint: .top, endPoint: .bottom
        )
    }
    static var waterGradient: LinearGradient {
        LinearGradient(colors: [sky, water], startPoint: .top, endPoint: .bottom)
    }
}
