//
//  LogWeightSheet.swift
//  CalorieBuddy
//
//  Log a dated weigh-in. Inserts a WeightEntry (the source of the weight
//  trend), keeps the profile's current weight in sync for today's entry, and
//  mirrors to Apple Health.
//

import SwiftUI
import SwiftData

struct LogWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(HealthKitService.self) private var health
    @Query private var profiles: [UserProfile]

    @State private var date = Date.now
    @State private var weightKg: Double

    init(initialKg: Double = 70) {
        _weightKg = State(initialValue: initialKg)
    }

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    DatePicker("Date", selection: $date,
                               in: ...Date.now, displayedComponents: .date)
                }
                Section("Weight") {
                    Stepper(value: $weightKg, in: 30...300, step: 0.1) {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text(String(format: "%.1f kg", weightKg))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle("Log weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        let entry = WeightEntry(weightKg: weightKg, date: date)
        context.insert(entry)
        // Today's weigh-in is the new "current" weight; recompute the plan since
        // body weight drives BMR/TDEE. Back-dated entries only fill the trend.
        if Calendar.current.isDateInToday(date), let profile {
            profile.currentWeightKg = weightKg
            profile.recomputePlan()
        }
        try? context.save()
        Task { await health.saveWeight(kg: weightKg, date: date) }
        Haptics.success()
        dismiss()
    }
}

#Preview {
    LogWeightSheet(initialKg: 72)
        .environment(HealthKitService())
        .modelContainer(AppContainer.preview)
}
