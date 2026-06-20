//
//  AppState.swift
//  CalorieBuddy
//
//  App-wide UI state (navigation, sheets, appearance). Injected via
//  `.environment(_:)` and observed with the Observation framework.
//

import SwiftUI
import Observation

enum AppColorSchemeOption: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "Automatic"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@Observable
final class AppState {
    enum Tab: Hashable {
        case today, diary, stats, settings
    }

    var selectedTab: Tab = .today
    var appColorScheme: AppColorSchemeOption = .system

    /// The day currently being viewed on the dashboard / diary.
    var selectedDate: Date = Calendar.current.startOfDay(for: .now)

    // Global sheets
    var isShowingScanner = false
    var isShowingPaywall = false
    var paywallContext = ""

    var preferredColorScheme: ColorScheme? { appColorScheme.colorScheme }

    func presentScanner() {
        Haptics.medium()
        isShowingScanner = true
    }

    func presentPaywall(context: String = "") {
        paywallContext = context
        isShowingPaywall = true
    }

    func goToToday() {
        selectedDate = Calendar.current.startOfDay(for: .now)
        selectedTab = .today
    }
}
