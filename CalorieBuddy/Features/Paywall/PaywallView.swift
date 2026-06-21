//
//  PaywallView.swift
//  CalorieBuddy
//
//  CalorieBuddy Plus paywall, driven by StoreService products.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var store

    @State private var selected: Product?
    @State private var purchasing = false

    private let features: [(icon: String, text: String)] = [
        ("infinity", "Unlimited AI meal scans"),
        ("barcode.viewfinder", "Barcode & nutrition-label scanning"),
        ("chart.bar.xaxis", "Full stats, trends & history"),
        ("timer", "Advanced fasting & water goals"),
        ("paintbrush.fill", "App icons, themes & your buddy"),
        ("rosette", "Awards & nutrition deep-dives"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    hero
                    featureList
                    plans
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Theme.background)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.inkTertiary) }
                }
            }
            .safeAreaInset(edge: .bottom) { purchaseBar }
            .task {
                if store.products.isEmpty { await store.loadProducts() }
                selected = store.products.first
            }
            .onChange(of: store.isPro) { _, isPro in
                if isPro { dismiss() }
            }
        }
    }

    private var hero: some View {
        VStack(spacing: Spacing.sm) {
            MascotView(mood: .excited, size: 104)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.amber)
                        .offset(x: 6, y: -4)
                }
            Text("CalorieBuddy Plus")
                .font(CBFont.largeTitle)
                .foregroundStyle(Theme.ink)
            Text("Unlock everything and reach your goals faster.")
                .font(CBFont.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.inkSecondary)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(features, id: \.text) { feature in
                HStack(spacing: Spacing.md) {
                    Image(systemName: feature.icon)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 28)
                    Text(feature.text)
                        .font(CBFont.body)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    private var plans: some View {
        VStack(spacing: Spacing.sm) {
            if store.products.isEmpty {
                Text("Subscription options are unavailable. Configure StoreKit in Xcode to test purchases.")
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, Spacing.md)
            } else {
                ForEach(store.products, id: \.id) { product in
                    PlanRow(product: product, isSelected: selected?.id == product.id) {
                        Haptics.selection()
                        selected = product
                    }
                }
            }
        }
    }

    private var purchaseBar: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                subscribe()
            } label: {
                if purchasing {
                    ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Theme.accent, in: Capsule())
                } else {
                    Text(ctaTitle)
                        .font(CBFont.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Theme.accent, in: Capsule())
                }
            }
            .buttonStyle(.plain)
            .disabled(selected == nil || purchasing)
            .opacity(selected == nil ? 0.5 : 1)

            HStack(spacing: Spacing.lg) {
                Button("Restore") { Task { await store.restore() } }
                Text("·")
                Text("Terms & Privacy")
            }
            .font(CBFont.caption)
            .foregroundStyle(Theme.inkTertiary)
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
    }

    private var ctaTitle: String {
        guard let selected else { return "Continue" }
        if let offer = selected.subscription?.introductoryOffer, offer.paymentMode == .freeTrial {
            return "Start free trial"
        }
        return "Subscribe"
    }

    private func subscribe() {
        guard let product = selected else { return }
        purchasing = true
        Task {
            let outcome = await store.purchase(product)
            purchasing = false
            if outcome == .success { dismiss() }
        }
    }
}

private struct PlanRow: View {
    let product: Product
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? Theme.accent : Theme.separator)
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName).font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
                    if let sub = subtitle {
                        Text(sub).font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice).font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
                    Text(periodText).font(CBFont.caption2).foregroundStyle(Theme.inkSecondary)
                }
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

    private var periodText: String {
        guard let unit = product.subscription?.subscriptionPeriod.unit else { return "" }
        switch unit {
        case .day: return "/ day"
        case .week: return "/ week"
        case .month: return "/ month"
        case .year: return "/ year"
        @unknown default: return ""
        }
    }

    private var subtitle: String? {
        if let offer = product.subscription?.introductoryOffer, offer.paymentMode == .freeTrial {
            return "Includes a free trial"
        }
        if product.subscription?.subscriptionPeriod.unit == .year {
            let perWeek = product.price / 52
            return "≈ \(perWeek.formatted(product.priceFormatStyle)) / week · best value"
        }
        return nil
    }
}
