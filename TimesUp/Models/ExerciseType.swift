import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case pushUps = "Push-ups"
    case squats = "Squats"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pushUps: return "figure.strengthtraining.traditional"
        case .squats: return "figure.squats"
        }
    }

    var instruction: String {
        switch self {
        case .pushUps: return "Place your phone to the side and do push-ups"
        case .squats: return "Place your phone in front and do squats"
        }
    }
}
