//
//  NotificationService.swift
//  CalorieBuddy
//
//  Local notifications for meal-logging reminders and fasting milestones.
//

import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {
    static let dailyReminderID = "cb.daily.log"
    static let fastingEndID = "cb.fasting.end"

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Schedule a repeating daily reminder at the given time.
    func scheduleDailyReminder(hour: Int, minute: Int = 0, mascotName: String = "Buddy") {
        let content = UNMutableNotificationContent()
        content.title = "Time to check in 🥗"
        content.body = "\(mascotName) is waiting — log your meals to keep your streak alive."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailyReminderID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderID])
        center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderID])
    }

    /// One-shot notification when a fast reaches its target end time.
    func scheduleFastingEnd(at date: Date, targetHours: Int) {
        guard date > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Fast complete! 🎉"
        content.body = "You've hit your \(targetHours)h fasting goal. Nicely done."
        content.sound = .default

        let interval = max(1, date.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: Self.fastingEndID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.fastingEndID])
        center.add(request)
    }

    func cancelFastingEnd() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.fastingEndID])
    }
}
