import SwiftUI
import SwiftData
import UserNotifications

@main
struct TimesUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .task {
                    await NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(for: Alarm.self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let alarmId = notification.request.identifier
        NotificationCenter.default.post(
            name: .alarmTriggered,
            object: nil,
            userInfo: ["alarmId": alarmId]
        )
        return [.sound, .banner]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let alarmId = response.notification.request.identifier
        NotificationCenter.default.post(
            name: .alarmTriggered,
            object: nil,
            userInfo: ["alarmId": alarmId]
        )
    }
}
