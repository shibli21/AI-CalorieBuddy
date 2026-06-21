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

    /// The app's single logging streak, creating and inserting one if none exists
    /// yet. Keeps the streak working even if it was never seeded at onboarding.
    @MainActor
    @discardableResult
    static func streak(in context: ModelContext) -> Streak {
        if let existing = try? context.fetch(FetchDescriptor<Streak>()).first { return existing }
        let created = Streak()
        context.insert(created)
        return created
    }

    /// Register a log against the streak; returns the new streak count only if
    /// it advanced (so callers can trigger a celebration). Falls back to the
    /// stored/created streak when `streak` is nil so logging always counts.
    @MainActor
    static func registerStreak(_ streak: Streak?, on date: Date, in context: ModelContext) -> Int? {
        let target = streak ?? self.streak(in: context)
        let before = target.current
        target.registerLog(on: date)
        return target.current > before ? target.current : nil
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
