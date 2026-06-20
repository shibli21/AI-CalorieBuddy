//
//  ScanQuota.swift
//  CalorieBuddy
//
//  Tracks free-tier daily AI scans. Pro is unlimited.
//

import Foundation

enum ScanQuota {
    static let freeDailyLimit = 3

    private static let countKey = "cb.scan.count"
    private static let dayKey = "cb.scan.day"

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: .now)
    }

    static func todayCount() -> Int {
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: dayKey) == todayString else { return 0 }
        return defaults.integer(forKey: countKey)
    }

    static func remaining(isPro: Bool) -> Int {
        isPro ? .max : max(0, freeDailyLimit - todayCount())
    }

    static func canScan(isPro: Bool) -> Bool {
        isPro || todayCount() < freeDailyLimit
    }

    static func record() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: dayKey) != todayString {
            defaults.set(todayString, forKey: dayKey)
            defaults.set(0, forKey: countKey)
        }
        defaults.set(defaults.integer(forKey: countKey) + 1, forKey: countKey)
    }
}
