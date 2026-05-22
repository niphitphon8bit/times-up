import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var time: Date
    var exerciseTypeRaw: String
    var soundRaw: String = AlarmSound.classic.rawValue
    var requiredReps: Int
    var isEnabled: Bool
    var label: String

    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .pushUps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    var sound: AlarmSound {
        get { AlarmSound(rawValue: soundRaw) ?? .classic }
        set { soundRaw = newValue.rawValue }
    }

    init(time: Date, exerciseType: ExerciseType, requiredReps: Int = 10, label: String = "Alarm", sound: AlarmSound = .classic) {
        self.id = UUID()
        self.time = time
        self.exerciseTypeRaw = exerciseType.rawValue
        self.soundRaw = sound.rawValue
        self.requiredReps = requiredReps
        self.isEnabled = true
        self.label = label
    }

    var timeString: String {
        Alarm.timeFormatter.string(from: time)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var notificationIdentifier: String {
        id.uuidString
    }
}
