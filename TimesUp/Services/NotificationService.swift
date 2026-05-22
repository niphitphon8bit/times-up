import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleAlarm(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Times Up!"
        content.body = "\(alarm.label) — Do \(alarm.requiredReps) \(alarm.exerciseType.rawValue) to dismiss"
        content.sound = .defaultRingtone
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "ALARM"

        let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: alarm.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [alarm.notificationIdentifier])
    }

    func cancelAllAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
