//
//  ProGate.swift
//  CalorieBuddy
//
//  Freemium gating: a declarative way to lock Pro-only surfaces behind the
//  StoreService entitlement and route to the paywall. Use `ProGate` / the
//  `ProUpsellCard` on tab-level screens (Stats, Settings); sheet-hosted screens
//  (Fasting, Water, Scan) present the paywall via a local sheet instead, because
//  the app-level paywall sheet sits behind them.
//

import SwiftUI

/// A Pro-only capability, with the copy shown on its upsell card and the
/// analytics/paywall context string passed to the paywall.
enum ProFeature {
    case stats, fastingPresets, fastingHistory, waterGoals, customization, labelScan, barcodeScan, aiCoach

    var context: String {
        switch self {
        case .stats: "stats"
        case .fastingPresets: "fasting-presets"
        case .fastingHistory: "fasting-history"
        case .waterGoals: "water-goals"
        case .customization: "customization"
        case .labelScan: "label-scan"
        case .barcodeScan: "barcode-scan"
        case .aiCoach: "ai-coach"
        }
    }

    var title: String {
        switch self {
        case .stats: "Unlock your full stats"
        case .fastingPresets: "More fasting presets"
        case .fastingHistory: "See your fasting history"
        case .waterGoals: "Custom water goals"
        case .customization: "Make it yours"
        case .labelScan: "Scan nutrition labels"
        case .barcodeScan: "Scan barcodes"
        case .aiCoach: "Chat with your AI coach"
        }
    }

    var blurb: String {
        switch self {
        case .stats: "Trends, weekly & monthly charts, and weight history."
        case .fastingPresets: "Pick any fasting window, not just 16:8."
        case .fastingHistory: "Review every fast and keep your streak going."
        case .waterGoals: "Set a custom daily hydration target."
        case .customization: "App icons, dashboard themes, and more."
        case .labelScan: "Point at a nutrition label and log it instantly."
        case .barcodeScan: "Scan a barcode to log packaged foods."
        case .aiCoach: "Ask anything about your nutrition and goals, any time."
        }
    }
}

/// Wraps Pro-only content, swapping it for an upsell card when the user isn't
/// subscribed. Routes to the paywall via `AppState` — use only where the
/// app-level paywall sheet can present (i.e. not from inside another sheet).
struct ProGate<Content: View>: View {
    let feature: ProFeature
    @ViewBuilder var content: () -> Content
    @Environment(StoreService.self) private var store

    var body: some View {
        if store.isPro {
            content()
        } else {
            ProUpsellCard(feature: feature)
        }
    }
}

/// A tappable card prompting the user to upgrade for a specific feature.
struct ProUpsellCard: View {
    let feature: ProFeature
    /// Optional override for how the paywall is presented. Defaults to the
    /// app-level paywall via `AppState`; sheet-hosted callers pass a local one.
    var present: (() -> Void)? = nil
    @Environment(AppState.self) private var appState

    var body: some View {
        Button {
            if let present { present() } else { appState.presentPaywall(context: feature.context) }
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.amber)
                VStack(alignment: .leading, spacing: 2) {
                    Text(feature.title).font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
                    Text(feature.blurb).font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: Spacing.sm)
                Text("Plus").font(CBFont.caption.weight(.bold)).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Theme.accent, in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cbCard()
        }
        .buttonStyle(.plain)
    }
}

/// Small lock badge to overlay on Pro-only controls.
struct ProLockChip: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(5)
            .background(Theme.amber, in: Circle())
    }
}

/// External links used on the paywall / legal surfaces.
enum AppLinks {
    /// Apple's standard EULA, used unless a custom Terms of Use is hosted.
    static let termsEULA = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}
