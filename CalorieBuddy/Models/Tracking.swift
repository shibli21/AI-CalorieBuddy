//
//  Tracking.swift
//  CalorieBuddy
//
//  Water, weight, fasting, streak, and award models. All CloudKit-safe.
//

import Foundation
import SwiftData

@Model
final class WaterLog {
    var id: UUID = UUID()
    var loggedAt: Date = Date.now
    var amountMl: Int = 0
    /// Start-of-day bucket for fast per-day queries.
    var day: Date = Calendar.current.startOfDay(for: .now)

    init(amountMl: Int = 0, loggedAt: Date = .now) {
        self.amountMl = amountMl
        self.loggedAt = loggedAt
        self.day = Calendar.current.startOfDay(for: loggedAt)
    }
}

@Model
final class WeightEntry {
    var id: UUID = UUID()
    var date: Date = Calendar.current.startOfDay(for: .now)
    var weightKg: Double = 0
    var fromHealthKit: Bool = false

    init(weightKg: Double = 0, date: Date = .now, fromHealthKit: Bool = false) {
        self.weightKg = weightKg
        self.date = Calendar.current.startOfDay(for: date)
        self.fromHealthKit = fromHealthKit
    }
}

@Model
final class FastingSession {
    var id: UUID = UUID()
    var startAt: Date = Date.now
    var endAt: Date? = nil
    var targetHours: Int = 16
    var includedLastMeal: Bool = false
    var stateRaw: String = FastingState.active.rawValue

    init(startAt: Date = .now, targetHours: Int = 16, includedLastMeal: Bool = false) {
        self.startAt = startAt
        self.targetHours = targetHours
        self.includedLastMeal = includedLastMeal
    }

    var state: FastingState {
        get { FastingState(rawValue: stateRaw) ?? .active }
        set { stateRaw = newValue.rawValue }
    }

    var targetEnd: Date { startAt.addingTimeInterval(TimeInterval(targetHours) * 3600) }

    /// Elapsed time, measured to `now` while active or to `endAt` once finished.
    func elapsed(now: Date = .now) -> TimeInterval {
        (endAt ?? now).timeIntervalSince(startAt)
    }

    /// Progress 0...1 toward the target window.
    func progress(now: Date = .now) -> Double {
        let target = TimeInterval(targetHours) * 3600
        guard target > 0 else { return 0 }
        return min(1, max(0, elapsed(now: now) / target))
    }
}

@Model
final class Streak {
    var id: UUID = UUID()
    var current: Int = 0
    var longest: Int = 0
    var lastLoggedDay: Date? = nil

    init() {}

    /// Register a log on `day`; advances or resets the streak.
    func registerLog(on day: Date = .now) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: day)
        guard let last = lastLoggedDay.map({ cal.startOfDay(for: $0) }) else {
            current = 1
            longest = max(longest, current)
            lastLoggedDay = today
            return
        }
        if cal.isDate(last, inSameDayAs: today) { return }
        if let next = cal.date(byAdding: .day, value: 1, to: last), cal.isDate(next, inSameDayAs: today) {
            current += 1
        } else {
            current = 1
        }
        longest = max(longest, current)
        lastLoggedDay = today
    }
}

@Model
final class AwardRecord {
    var id: UUID = UUID()
    var key: String = ""
    var earnedAt: Date = Date.now

    init(key: String = "", earnedAt: Date = .now) {
        self.key = key
        self.earnedAt = earnedAt
    }
}
