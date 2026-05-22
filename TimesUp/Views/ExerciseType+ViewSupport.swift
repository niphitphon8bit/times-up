import Foundation

extension ExerciseType {
    var icon: String {
        switch self {
        case .pushUps: return "figure.core.training"
        case .squats: return "figure.strengthtraining.functional"
        }
    }

    var instruction: String {
        switch self {
        case .pushUps: return "Place your phone to the side and do push-ups"
        case .squats: return "Place your phone in front and do squats"
        }
    }
}
