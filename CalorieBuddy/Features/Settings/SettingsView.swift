//
//  SettingsView.swift
//  CalorieBuddy
//
//  Settings hub: plan, details, preferences, customization, about, account.
//

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Environment(StoreService.self) private var store
    @Environment(NotificationService.self) private var notifications
    @Query private var profiles: [UserProfile]

    @State private var showDelete = false
    @State private var showReset = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        @Bindable var appState = appState

        NavigationStack {
            Form {
                if let profile {
                    Section { header(profile) }
                }

                Section {
                    if store.isPro {
                        Label("CalorieBuddy Plus is active", systemImage: "crown.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button {
                            appState.presentPaywall(context: "settings")
                        } label: {
                            Label("Upgrade to Plus", systemImage: "crown.fill")
                        }
                    }
                }

                if let profile {
                    Section("Your plan") {
                        NavigationLink { EditPlanView(profile: profile) } label: {
                            Label("Calories & macros", systemImage: "flame.fill")
                        }
                        NavigationLink { PersonalDetailsView(profile: profile) } label: {
                            Label("Personal details", systemImage: "person.fill")
                        }
                        NavigationLink { EatingPrefsView(profile: profile) } label: {
                            Label("Eating preferences", systemImage: "fork.knife")
                        }
                    }

                    Section("Preferences") {
                        Picker("Units", selection: unitsBinding(profile)) {
                            ForEach(MeasurementSystem.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Calories display", selection: caloriesBinding(profile)) {
                            ForEach(CaloriesDisplayMode.allCases) { Text($0.title).tag($0) }
                        }
                        Picker("Appearance", selection: $appState.appColorScheme) {
                            ForEach(AppColorSchemeOption.allCases) { Text($0.title).tag($0) }
                        }
                        Toggle("Daily reminder", isOn: reminderBinding(profile))
                        if profile.remindersEnabled {
                            Stepper(value: reminderHourBinding(profile), in: 0...23) {
                                HStack {
                                    Text("Reminder time")
                                    Spacer()
                                    Text(EatingWindowStep.hourLabel(profile.reminderHour)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Section("Customization") {
                        NavigationLink { AppIconPickerView() } label: {
                            Label("App icon", systemImage: "app.badge.fill")
                        }
                        NavigationLink { MascotNameView(profile: profile) } label: {
                            Label("Your buddy", systemImage: "pawprint.fill")
                        }
                    }
                }

                Section("About") {
                    Button {
                        Task { await store.restore() }
                    } label: {
                        Label("Restore purchases", systemImage: "arrow.clockwise")
                    }
                    NavigationLink { PrivacyView() } label: {
                        Label("Privacy Notice", systemImage: "hand.raised.fill")
                    }
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion).foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button { showReset = true } label: {
                        Label("Replay onboarding", systemImage: "arrow.counterclockwise")
                    }
                    Button(role: .destructive) { showDelete = true } label: {
                        Label("Delete all data", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Replay onboarding?", isPresented: $showReset) {
                Button("Replay", role: .destructive) { resetOnboarding() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your logged data is kept; you'll go through setup again.")
            }
            .alert("Delete all data?", isPresented: $showDelete) {
                Button("Delete everything", role: .destructive) { deleteAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes your profile and all logged meals, water, weight, and fasts.")
            }
        }
    }

    // MARK: Header

    private func header(_ profile: UserProfile) -> some View {
        HStack(spacing: Spacing.md) {
            MascotView(mood: .happy, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.mascotName).font(CBFont.title3).foregroundStyle(Theme.ink)
                Text("\(profile.calorieTarget) kcal · \(profile.goal.title)")
                    .font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
            }
            Spacer()
        }
    }

    // MARK: Bindings

    private func unitsBinding(_ p: UserProfile) -> Binding<MeasurementSystem> {
        Binding(get: { p.measurementSystem }, set: { p.measurementSystem = $0; try? context.save() })
    }
    private func caloriesBinding(_ p: UserProfile) -> Binding<CaloriesDisplayMode> {
        Binding(get: { p.caloriesDisplayMode }, set: { p.caloriesDisplayMode = $0; try? context.save() })
    }
    private func reminderBinding(_ p: UserProfile) -> Binding<Bool> {
        Binding(get: { p.remindersEnabled }, set: { newValue in
            p.remindersEnabled = newValue
            try? context.save()
            if newValue {
                Task {
                    _ = await notifications.requestAuthorization()
                    notifications.scheduleDailyReminder(hour: p.reminderHour, mascotName: p.mascotName)
                }
            } else {
                notifications.cancelDailyReminder()
            }
        })
    }
    private func reminderHourBinding(_ p: UserProfile) -> Binding<Int> {
        Binding(get: { p.reminderHour }, set: { newValue in
            p.reminderHour = newValue
            try? context.save()
            if p.remindersEnabled {
                notifications.scheduleDailyReminder(hour: newValue, mascotName: p.mascotName)
            }
        })
    }

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }

    // MARK: Actions

    private func resetOnboarding() {
        profile?.onboardingCompleted = false
        try? context.save()
        Haptics.warning()
    }

    private func deleteAllData() {
        try? context.delete(model: FoodEntry.self)
        try? context.delete(model: Ingredient.self)
        try? context.delete(model: DiaryDay.self)
        try? context.delete(model: WaterLog.self)
        try? context.delete(model: WeightEntry.self)
        try? context.delete(model: FastingSession.self)
        try? context.delete(model: Streak.self)
        try? context.delete(model: AwardRecord.self)
        try? context.delete(model: UserProfile.self)
        try? context.save()
        Haptics.warning()
    }
}

struct AppIconPickerView: View {
    private let icons: [(name: String?, label: String)] = [
        (nil, "Default"), ("AppIconMint", "Mint"), ("AppIconBerry", "Berry"), ("AppIconNight", "Night"),
    ]
    @State private var current = UIApplication.shared.alternateIconName

    var body: some View {
        List {
            Section {
                ForEach(icons, id: \.label) { icon in
                    Button { setIcon(icon.name) } label: {
                        HStack {
                            Image(systemName: "app.fill").foregroundStyle(Theme.accent)
                            Text(icon.label).foregroundStyle(Theme.ink)
                            Spacer()
                            if current == icon.name {
                                Image(systemName: "checkmark").foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }
            } footer: {
                Text("Alternate icons require icon assets in the asset catalog.")
            }
        }
        .navigationTitle("App icon")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setIcon(_ name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(name) { _ in }
        current = name
        Haptics.selection()
    }
}

struct MascotNameView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    var body: some View {
        Form {
            Section {
                HStack { Spacer(); MascotView(mood: .happy, size: 72); Spacer() }
            }
            Section("Your buddy's name") {
                TextField("Buddy", text: $profile.mascotName)
            }
        }
        .navigationTitle("Your buddy")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if profile.mascotName.trimmingCharacters(in: .whitespaces).isEmpty { profile.mascotName = "Buddy" }
            try? context.save()
        }
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Privacy Notice").font(CBFont.title2).foregroundStyle(Theme.ink)
                Text("""
                CalorieBuddy stores your data on your device using Apple's SwiftData, and optionally syncs it to your private iCloud account via CloudKit. Your data is not sold.

                When you scan a meal, the photo is sent securely to our AI service to estimate its nutrition. Photos are used only to produce that estimate.

                You can write your nutrition, water, and weight to Apple Health with your permission, and revoke access at any time in the Health app.

                You can delete all of your data at any time from Settings → Delete all data.
                """)
                .font(CBFont.body)
                .foregroundStyle(Theme.inkSecondary)
            }
            .padding(Spacing.screen)
        }
        .background(Theme.background)
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
