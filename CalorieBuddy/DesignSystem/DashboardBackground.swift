//
//  DashboardBackground.swift
//  CalorieBuddy
//
//  Selectable dashboard background themes (a Pro customization). Implemented as
//  soft, content-safe gradients over the adaptive base background, so they read
//  well in light and dark mode without any image assets.
//

import SwiftUI

enum DashboardBackground: String, CaseIterable, Identifiable {
    case `default`, sunrise, mint, ocean, dusk, blossom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: "Default"
        case .sunrise: "Sunrise"
        case .mint: "Mint"
        case .ocean: "Ocean"
        case .dusk: "Dusk"
        case .blossom: "Blossom"
        }
    }

    /// A soft background that keeps foreground content readable.
    @ViewBuilder
    var view: some View {
        switch self {
        case .default: Theme.background
        case .sunrise: gradient(Theme.amber)
        case .mint: gradient(Theme.accent)
        case .ocean: gradient(Theme.water)
        case .dusk: gradient(Theme.grape)
        case .blossom: gradient(Theme.berry)
        }
    }

    private func gradient(_ tint: Color) -> some View {
        LinearGradient(colors: [tint.opacity(0.22), Theme.background],
                       startPoint: .top, endPoint: .bottom)
    }
}

/// Pro customization picker for the dashboard background.
struct DashboardBackgroundPickerView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: Spacing.md)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(DashboardBackground.allCases) { bg in
                    let isSelected = profile.dashboardBackground == bg
                    Button {
                        profile.dashboardBackground = bg
                        try? context.save()
                        Haptics.selection()
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            bg.view
                                .frame(height: 90)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                        .strokeBorder(isSelected ? Theme.accent : Theme.separator,
                                                      lineWidth: isSelected ? 3 : 1)
                                )
                            Text(bg.title).font(CBFont.caption).foregroundStyle(Theme.ink)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.screen)
        }
        .background(Theme.background)
        .navigationTitle("Background")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DashboardBackgroundPickerView(profile: UserProfile())
            .modelContainer(AppContainer.preview)
    }
}
