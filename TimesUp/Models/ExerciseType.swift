import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case pushUps = "Push-ups"
    case squats = "Squats"

    var id: String { rawValue }
}
