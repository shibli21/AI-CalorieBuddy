//
//  ScanFlowView.swift
//  CalorieBuddy
//
//  Orchestrates capture → analyze → review → log. Presented from the center
//  scan button. Falls back to a mock result when no AI proxy is configured.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AIService.self) private var ai
    @Environment(HealthKitService.self) private var health
    @Environment(StoreService.self) private var store
    @Environment(AppState.self) private var appState
    @Query private var streaks: [Streak]

    @State private var vm = ScanViewModel()
    @State private var showCamera = false
    @State private var showPaywall = false
    @State private var libraryItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Group {
                switch vm.phase {
                case .capture: captureView
                case .analyzing: AnalyzingView(image: vm.image)
                case .review: ScanReviewView(vm: vm, onSave: saveMeal, onRetake: { vm.phase = .capture })
                case .error: errorView
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .background(Theme.background)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in handle(image) }
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .onChange(of: vm.mode) { _, newMode in
            // Nutrition-label & barcode scanning are Pro features (SPEC §3).
            if !store.isPro && newMode != .meal {
                vm.mode = .meal
                showPaywall = true
            }
        }
        .onChange(of: libraryItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    handle(image)
                }
                libraryItem = nil
            }
        }
    }

    private var navTitle: String {
        switch vm.phase {
        case .review: "Review meal"
        case .analyzing: "Analyzing"
        default: "Scan a meal"
        }
    }

    // MARK: Capture

    private var captureView: some View {
        VStack(spacing: Spacing.lg) {
            Picker("Mode", selection: $vm.mode) {
                ForEach(ScanMode.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.screen)

            Spacer()

            MascotView(mood: .scanning, size: 120)
            Text(vm.mode == .label ? "Scan a nutrition label" : "Snap your meal")
                .font(CBFont.title2)
                .foregroundStyle(Theme.ink)
            Text("Center your \(vm.mode == .label ? "label" : "plate") and keep it well lit.")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            if !ai.isConfigured {
                Label("Demo mode — add a proxy URL to enable real AI.", systemImage: "info.circle")
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkTertiary)
            }

            Spacer()

            VStack(spacing: Spacing.md) {
                if CameraPicker.isAvailable {
                    Button {
                        if quotaOK() { showCamera = true }
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
                    }
                    .buttonStyle(.cbPrimary)
                }
                PhotosPicker(selection: $libraryItem, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .font(CBFont.headline)
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.surfaceAlt, in: Capsule())
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.lg)
        }
        .padding(.top, Spacing.md)
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.amber)
            Text("Scan failed").font(CBFont.title2).foregroundStyle(Theme.ink)
            Text(vm.errorMessage ?? "Something went wrong.")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Spacer()
            Button("Try again") { vm.phase = .capture }
                .buttonStyle(.cbPrimary)
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: Actions

    private func handle(_ image: UIImage) {
        guard quotaOK() else { return }
        vm.loggedAt = combinedTimestamp()
        Task { await vm.analyze(image: image, ai: ai) }
    }

    private func quotaOK() -> Bool {
        if ScanQuota.canScan(isPro: store.isPro) { return true }
        dismiss()
        appState.presentPaywall(context: "scan-limit")
        return false
    }

    private func combinedTimestamp() -> Date {
        let cal = Calendar.current
        if cal.isDateInToday(appState.selectedDate) { return .now }
        let now = cal.dateComponents([.hour, .minute], from: .now)
        return cal.date(bySettingHour: now.hour ?? 12, minute: now.minute ?? 0, second: 0, of: appState.selectedDate)
            ?? appState.selectedDate
    }

    private func saveMeal() {
        let advanced = vm.save(context: context, health: health, streak: streaks.first)
        dismiss()
        appState.goToToday()
        if let advanced { appState.celebrationDay = advanced }
    }
}

struct AnalyzingView: View {
    var image: UIImage?

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                                .fill(.black.opacity(0.25))
                        )
                } else {
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .fill(Theme.surfaceAlt)
                        .frame(width: 220, height: 220)
                }
                MascotView(mood: .hungry, size: 64)
            }
            VStack(spacing: Spacing.sm) {
                Text("Analyzing your food…")
                    .font(CBFont.title2)
                    .foregroundStyle(Theme.ink)
                PulsingDots()
            }
            Spacer()
        }
    }
}
