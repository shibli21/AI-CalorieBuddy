//
//  DiaryStore.swift
//  CalorieBuddy
//
//  Small helpers for fetching/creating the DiaryDay bucket for a date.
//

import Foundation
import SwiftData

enum DiaryStore {
    @MainActor
    static func day(for date: Date, in context: ModelContext) -> DiaryDay {
        let start = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<DiaryDay>(predicate: #Predicate { $0.date == start })
        if let existing = try? context.fetch(descriptor).first { return existing }
        let day = DiaryDay(date: start)
        context.insert(day)
        return day
    }

    /// Register a log against the streak; returns the new streak count only if
    /// it advanced (so callers can trigger a celebration).
    @MainActor
    static func registerStreak(_ streak: Streak?, on date: Date) -> Int? {
        guard let streak else { return nil }
        let before = streak.current
        streak.registerLog(on: date)
        return streak.current > before ? streak.current : nil
    }

    /// Timestamp to use when logging on a given calendar day: now if it's today,
    /// otherwise the current time-of-day on that day.
    static func timestamp(for date: Date) -> Date {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return .now }
        let now = cal.dateComponents([.hour, .minute], from: .now)
        return cal.date(bySettingHour: now.hour ?? 12, minute: now.minute ?? 0, second: 0, of: date) ?? date
    }
}
