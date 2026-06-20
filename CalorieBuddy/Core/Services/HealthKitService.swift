//
//  HealthKitService.swift
//  CalorieBuddy
//
//  Opt-in mirror to Apple Health: writes nutrition/water/weight, reads weight
//  and active energy to inform the daily budget. SwiftData stays canonical.
//

import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService {
    private let store = HKHealthStore()
    var isAuthorized = false

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    private var writeTypes: Set<HKSampleType> {
        [
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryFiber),
            HKQuantityType(.dietaryWater),
            HKQuantityType(.bodyMass),
        ]
    }

    private var readTypes: Set<HKObjectType> {
        [
            HKQuantityType(.bodyMass),
            HKQuantityType(.activeEnergyBurned),
        ]
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }

    // MARK: - Writes

    func save(foodEntry entry: FoodEntry) async {
        guard isAvailable else { return }
        let when = entry.loggedAt
        var samples: [HKQuantitySample] = []
        func add(_ id: HKQuantityTypeIdentifier, _ value: Double, _ unit: HKUnit) {
            guard value > 0 else { return }
            samples.append(HKQuantitySample(type: HKQuantityType(id),
                                            quantity: HKQuantity(unit: unit, doubleValue: value),
                                            start: when, end: when))
        }
        add(.dietaryEnergyConsumed, Double(entry.totalKcal), .kilocalorie())
        add(.dietaryProtein, Double(entry.protein), .gram())
        add(.dietaryCarbohydrates, Double(entry.carbs), .gram())
        add(.dietaryFatTotal, Double(entry.fat), .gram())
        add(.dietaryFiber, Double(entry.fiber), .gram())
        guard !samples.isEmpty else { return }
        try? await store.save(samples)
    }

    func saveWater(ml: Int, date: Date = .now) async {
        guard isAvailable, ml > 0 else { return }
        let sample = HKQuantitySample(type: HKQuantityType(.dietaryWater),
                                      quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(ml)),
                                      start: date, end: date)
        try? await store.save(sample)
    }

    func saveWeight(kg: Double, date: Date = .now) async {
        guard isAvailable, kg > 0 else { return }
        let sample = HKQuantitySample(type: HKQuantityType(.bodyMass),
                                      quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg),
                                      start: date, end: date)
        try? await store.save(sample)
    }

    // MARK: - Reads

    /// Active energy burned (kcal) for the given day.
    func activeEnergy(on date: Date = .now) async -> Int {
        guard isAvailable else { return 0 }
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? date
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: HKQuantityType(.activeEnergyBurned), predicate: predicate),
            options: .cumulativeSum
        )
        let stats = try? await descriptor.result(for: store)
        let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        return Int(kcal.rounded())
    }

    /// Most recent body-mass reading (kg), if any.
    func latestWeightKg() async -> Double? {
        guard isAvailable else { return nil }
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.bodyMass))],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )
        let samples = try? await descriptor.result(for: store)
        return samples?.first?.quantity.doubleValue(for: .gramUnit(with: .kilo))
    }
}
