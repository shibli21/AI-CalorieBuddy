//
//  FastingView.swift
//  CalorieBuddy
//
//  Intermittent fasting: start a fast with a preset window, or watch a live
//  timer with metabolic stage labels and end/cancel controls.
//

import SwiftUI
import SwiftData

struct FastingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(NotificationService.self) private var notifications
    @Query private var fasts: [FastingSession]
    @Query private var profiles: [UserProfile]

    init() {
        _fasts = Query(sort: \FastingSession.startAt, order: .reverse)
    }

    private var active: FastingSession? { fasts.first { $0.state == .active } }
    private var recent: [FastingSession] { Array(fasts.filter { $0.state == .completed }.prefix(5)) }

    var body: some View {
        NavigationStack {
            Group {
                if let active {
                    ActiveFastingView(session: active, onEnd: endFast, onCancel: cancelFast)
                } else {
                    StartFastingView(recent: recent,
                                     defaultPreset: profiles.first?.fastingPresetHours ?? 16,
                                     onStart: startFast)
                }
            }
            .background(Theme.background)
            .navigationTitle("Fasting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() } }
            }
        }
    }

    private func startFast(targetHours: Int, start: Date, includeLastMeal: Bool) {
        let session = FastingSession(startAt: start, targetHours: targetHours, includedLastMeal: includeLastMeal)
        context.insert(session)
        try? context.save()
        notifications.scheduleFastingEnd(at: session.targetEnd, targetHours: targetHours)
        Haptics.success()
    }

    private func endFast() {
        guard let active else { return }
        active.endAt = .now
        active.state = .completed
        try? context.save()
        notifications.cancelFastingEnd()
        Haptics.success()
    }

    private func cancelFast() {
        guard let active else { return }
        active.endAt = .now
        active.state = .canceled
        try? context.save()
        notifications.cancelFastingEnd()
        Haptics.warning()
    }
}

private struct ActiveFastingView: View {
    let session: FastingSession
    var onEnd: () -> Void
    var onCancel: () -> Void

    @State private var showEarlyEnd = false
    @State private var showCancel = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let elapsed = session.elapsed(now: now)
            let progress = session.progress(now: now)
            let hours = elapsed / 3600

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    ZStack {
                        ProgressRing(progress: progress, lineWidth: 18, colors: [Theme.grape, Theme.sky])
                            .frame(width: 240, height: 240)
                        VStack(spacing: 4) {
                            Text(Self.hms(elapsed))
                                .font(CBFont.display(38))
                                .foregroundStyle(Theme.ink)
                                .monospacedDigit()
                            Text("of \(session.targetHours)h goal")
                                .font(CBFont.subheadline)
                                .foregroundStyle(Theme.inkSecondary)
                            Text(Self.stage(hours))
                                .font(CBFont.caption.weight(.semibold))
                                .foregroundStyle(Theme.grape)
                        }
                    }
                    .padding(.top, Spacing.lg)

                    HStack(spacing: Spacing.md) {
                        timeChip("Started", session.startAt, icon: "play.circle.fill")
                        timeChip("Goal", session.targetEnd, icon: "flag.checkered")
                    }

                    VStack(spacing: Spacing.md) {
                        Button(progress >= 1 ? "Complete fast" : "End fast early") {
                            if progress >= 1 { onEnd() } else { showEarlyEnd = true }
                        }
                        .buttonStyle(.cbPrimary)

                        Button("Cancel fast") { showCancel = true }
                            .font(CBFont.subheadline)
                            .foregroundStyle(Theme.berry)
                    }
                    .padding(.horizontal, Spacing.screen)
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.xxl)
            }
            .alert("End fast early?", isPresented: $showEarlyEnd) {
                Button("End now", role: .destructive) { onEnd() }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("You haven't reached your \(session.targetHours)h goal yet.")
            }
            .alert("Cancel this fast?", isPresented: $showCancel) {
                Button("Cancel fast", role: .destructive) { onCancel() }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("This won't count toward your streak.")
            }
        }
    }

    private func timeChip(_ label: String, _ date: Date, icon: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon).foregroundStyle(Theme.grape)
            Text(date.formatted(date: .omitted, time: .shortened))
                .font(CBFont.headline).foregroundStyle(Theme.ink)
            Text(label).font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .cbCard()
    }

    static func hms(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }

    static func stage(_ hours: Double) -> String {
        switch hours {
        case ..<4: "Fed state"
        case ..<12: "Fat burning"
        case ..<16: "Ketosis starting"
        case ..<24: "Deep ketosis"
        default: "Autophagy"
        }
    }
}

private struct StartFastingView: View {
    let recent: [FastingSession]
    var onStart: (Int, Date, Bool) -> Void

    @State private var preset: Int
    @State private var startNow = true
    @State private var customStart = Date.now
    @State private var includeLastMeal = false

    private static let presets = [12, 14, 16, 18]

    init(recent: [FastingSession], defaultPreset: Int, onStart: @escaping (Int, Date, Bool) -> Void) {
        self.recent = recent
        self.onStart = onStart
        _preset = State(initialValue: Self.presets.contains(defaultPreset) ? defaultPreset : 16)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack { Spacer(); MascotView(mood: .meditating, size: 100); Spacer() }
                Text("Choose your fasting goal")
                    .font(CBFont.title2)
                    .foregroundStyle(Theme.ink)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                    ForEach(Self.presets, id: \.self) { hours in
                        Button {
                            Haptics.selection()
                            preset = hours
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(hours):\(24 - hours)")
                                    .font(CBFont.title2)
                                    .foregroundStyle(preset == hours ? .white : Theme.ink)
                                Text("\(hours)h fast · \(24 - hours)h eat")
                                    .font(CBFont.caption)
                                    .foregroundStyle(preset == hours ? .white.opacity(0.9) : Theme.inkSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.lg)
                            .background(preset == hours ? Theme.grape : Theme.surface,
                                        in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                    .strokeBorder(preset == hours ? Color.clear : Theme.separator)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: Spacing.md) {
                    Toggle("Start now", isOn: $startNow.animation(.smooth)).tint(Theme.accent)
                    if !startNow {
                        DatePicker("Start time", selection: $customStart, displayedComponents: [.date, .hourAndMinute])
                    }
                    Divider().overlay(Theme.separator)
                    Toggle("I just finished my last meal", isOn: $includeLastMeal).tint(Theme.accent)
                }
                .cbCard()

                if !recent.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Recent fasts").font(CBFont.headline).foregroundStyle(Theme.ink)
                        ForEach(recent) { fast in
                            HStack {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.accent)
                                Text("\(fast.targetHours)h fast").font(CBFont.body).foregroundStyle(Theme.ink)
                                Spacer()
                                Text(fast.startAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(CBFont.caption).foregroundStyle(Theme.inkSecondary)
                            }
                            if fast.id != recent.last?.id { Divider().overlay(Theme.separator) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cbCard()
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Start fasting") {
                onStart(preset, startNow ? .now : customStart, includeLastMeal)
            }
            .buttonStyle(.cbPrimary)
            .padding(.horizontal, Spacing.screen)
            .padding(.vertical, Spacing.sm)
        }
    }
}
