import Foundation
import UserNotifications
import AudioToolbox

enum AlarmSound: String, CaseIterable, Codable, Identifiable {
    case classic = "Classic"
    case ringtone = "Ringtone"
    case digital = "Digital"
    case chime = "Chime"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .classic: return "bell.fill"
        case .ringtone: return "phone.fill"
        case .digital: return "waveform"
        case .chime: return "music.note"
        }
    }

    // Sound used for the notification trigger (background/killed app)
    var notificationSound: UNNotificationSound {
        switch self {
        case .ringtone: return .defaultRingtone
        default: return .default
        }
    }

    // System sound ID for in-app looped playback fallback
    var systemSoundID: SystemSoundID {
        switch self {
        case .classic: return 1005
        case .ringtone: return 1007
        case .digital: return 1022
        case .chime: return 1016
        }
    }

    func preview() {
        AudioServicesPlayAlertSound(systemSoundID)
    }
}
