//
//  WaterView.swift
//  CalorieBuddy
//
//  Hydration tracking for a day: bottle fill, quick add, goal, and history.
//

import SwiftUI
import SwiftData

struct WaterView: View {
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(HealthKitService.self) private var health
    @Environment(StoreService.self) private var store
    @Query private var profiles: [UserProfile]
    @Query private var waters: [WaterLog]

    @State private var showGoal = false
    @State private var showCustom = false
    @State private var showPaywall = false
    @State private var celebrated = false

    init(date: Date) {
        self.date = date
        let start = Calendar.current.startOfDay(for: date)
        _waters = Query(filter: #Predicate<WaterLog> { $0.day == start },
                        sort: \WaterLog.loggedAt, order: .reverse)
    }

    private var total: Int { waters.reduce(0) { $0 + $1.amountMl } }
    private var goal: Int { profiles.first?.waterGoalMl ?? 2500 }
    private var progress: Double { goal > 0 ? Double(total) / Double(goal) : 0 }
    private var reached: Bool { goal > 0 && total >= goal }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    WaterBottle(progress: progress)
                        .padding(.top, Spacing.lg)

                    HStack(spacing: Spacing.md) {
                        MascotView(mood: .drinkingWater, size: 56)
                        Text("\(total) / \(goal) ml")
                            .font(CBFont.title2)
                            .foregroundStyle(Theme.ink)
                            .contentTransition(.numericText())
                    }

                    quickAdds

                    if reached { celebration }

                    if !waters.isEmpty { history }
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Theme.background)
            .navigationTitle("Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Custom water goals are a Pro feature (SPEC §3).
                        if store.isPro { showGoal = true } else { showPaywall = true }
                    } label: {
                        Image(systemName: store.isPro ? "target" : "lock.fill")
                    }
                    .disabled(profiles.first == nil)
                }
            }
            .sheet(isPresented: $showCustom) {
                CustomWaterSheet { add($0) }
            }
            .sheet(isPresented: $showGoal) {
                if let profile = profiles.first {
                    WaterGoalSheet(profile: profile)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .onChange(of: reached) { _, isReached in
                if isReached && !celebrated {
                    celebrated = true
                    Haptics.success()
                }
            }
        }
    }

    private var quickAdds: some View {
        HStack(spacing: Spacing.md) {
            quickButton(label: "250 ml", systemImage: "cup.and.saucer.fill") { add(250) }
            quickButton(label: "500 ml", systemImage: "waterbottle.fill") { add(500) }
            quickButton(label: "Custom", systemImage: "slider.horizontal.3") { showCustom = true }
        }
    }

    private func quickButton(label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: systemImage).font(.title2).foregroundStyle(Theme.water)
                Text(label).font(CBFont.caption).foregroundStyle(Theme.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var celebration: some View {
        HStack(spacing: Spacing.md) {
            Text("🎉").font(.system(size: 34))
            VStack(alignment: .leading, spacing: 2) {
                Text("Goal reached!").font(CBFont.bodyEmphasized).foregroundStyle(Theme.ink)
                Text("Nicely hydrated today.").font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard(padding: Spacing.md, fill: Theme.accentSoft)
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Today's log").font(CBFont.headline).foregroundStyle(Theme.ink)
            ForEach(waters) { log in
                HStack {
                    Image(systemName: "drop.fill").foregroundStyle(Theme.water)
                    Text("\(log.amountMl) ml").font(CBFont.body).foregroundStyle(Theme.ink)
                    Spacer()
                    Text(log.loggedAt.formatted(date: .omitted, time: .shortened))
                        .font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                }
                .contextMenu {
                    Button(role: .destructive) { remove(log) } label: { Label("Delete", systemImage: "trash") }
                }
                if log.id != waters.last?.id { Divider().overlay(Theme.separator) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard()
    }

    private func add(_ ml: Int) {
        let log = WaterLog(amountMl: ml, loggedAt: DiaryStore.timestamp(for: date))
        context.insert(log)
        try? context.save()
        Task { await health.saveWater(ml: ml, date: log.loggedAt) }
    }

    private func remove(_ log: WaterLog) {
        context.delete(log)
        try? context.save()
        Haptics.warning()
    }
}

struct WaterBottle: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Theme.surfaceAlt)
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Theme.waterGradient)
                    .frame(height: geo.size.height * min(1, max(0, progress)))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(Theme.water.opacity(0.35), lineWidth: 2)
            )
            .overlay {
                Text("\(Int(min(1, max(0, progress)) * 100))%")
                    .font(CBFont.display(30))
                    .foregroundStyle(progress > 0.5 ? .white : Theme.ink)
            }
            .animation(.smooth(duration: 0.5), value: progress)
        }
        .frame(width: 140, height: 210)
        .frame(maxWidth: .infinity)
    }
}

struct CustomWaterSheet: View {
    var onAdd: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var amount = 300

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Stepper(value: $amount, in: 50...2000, step: 50) {
                    Text("\(amount) ml").font(CBFont.title2).foregroundStyle(Theme.ink)
                }
                .padding(.horizontal, Spacing.screen)
                Button("Add water") {
                    onAdd(amount)
                    dismiss()
                }
                .buttonStyle(.cbPrimary)
                .padding(.horizontal, Spacing.screen)
                Spacer()
            }
            .padding(.top, Spacing.xl)
            .background(Theme.background)
            .navigationTitle("Custom amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.height(240)])
    }
}

struct WaterGoalSheet: View {
    @Bindable var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var goal: Int

    init(profile: UserProfile) {
        self.profile = profile
        _goal = State(initialValue: profile.waterGoalMl)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Picker("Goal", selection: $goal) {
                    ForEach(Array(stride(from: 500, through: 5000, by: 250)), id: \.self) {
                        Text("\($0) ml").tag($0)
                    }
                }
                .pickerStyle(.wheel)
                Spacer()
            }
            .padding(.top, Spacing.md)
            .background(Theme.background)
            .navigationTitle("Daily water goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile.waterGoalMl = goal
                        try? context.save()
                        Haptics.success()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
