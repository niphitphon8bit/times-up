import Vision

protocol ExerciseDetector {
    mutating func processObservation(_ observation: VNHumanBodyPoseObservation) -> Int
    var repCount: Int { get }
    var isInPosition: Bool { get }
    mutating func reset()
}

enum ExerciseDetectorFactory {
    static func make(for type: ExerciseType) -> any ExerciseDetector {
        switch type {
        case .pushUps: return PushUpDetector()
        case .squats: return SquatDetector()
        }
    }
}
