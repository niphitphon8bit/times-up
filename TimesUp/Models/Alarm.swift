import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var time: Date
    var exerciseTypeRaw: String
    var requiredReps: Int
    var isEnabled: Bool
    var label: String

    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .pushUps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    init(time: Date, exerciseType: ExerciseType, requiredReps: Int = 10, label: String = "Alarm") {
        self.id = UUID()
        self.time = time
        self.exerciseTypeRaw = exerciseType.rawValue
        self.requiredReps = requiredReps
        self.isEnabled = true
        self.label = label
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var notificationIdentifier: String {
        id.uuidString
    }
}
