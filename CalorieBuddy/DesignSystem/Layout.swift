//
//  Layout.swift
//  CalorieBuddy
//
//  Spacing, corner-radius, and shadow tokens.
//

import SwiftUI

enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    /// Standard screen horizontal inset.
    static let screen: CGFloat = 20
}

enum Radius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let xl: CGFloat = 28
    static let pill: CGFloat = 999
}

struct CBShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let card = CBShadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    static let floating = CBShadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 12)
    static let subtle = CBShadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
}

extension View {
    func cbShadow(_ shadow: CBShadow = .card) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
