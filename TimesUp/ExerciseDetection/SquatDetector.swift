import Vision

struct SquatDetector: ExerciseDetector {
    private enum Phase { case unknown, standing, squatting }

    private var phase: Phase = .unknown
    private(set) var repCount = 0
    private(set) var isInPosition = false
    private var angleHistory: [Double] = []
    private let smoothingWindow = 5
    private let squatThreshold: Double = 100
    private let standThreshold: Double = 160
    private let holdFramesRequired = 3
    private var framesInCurrentState = 0

    mutating func processObservation(_ observation: VNHumanBodyPoseObservation) -> Int {
        let positions = extractPositions(from: observation)

        guard let kneeAngle = computeKneeAngle(positions: positions) else {
            isInPosition = false
            return repCount
        }

        isInPosition = true
        angleHistory.append(kneeAngle)
        if angleHistory.count > smoothingWindow {
            angleHistory.removeFirst()
        }

        let smoothedAngle = angleHistory.reduce(0, +) / Double(angleHistory.count)

        switch phase {
        case .unknown:
            if smoothedAngle > standThreshold {
                phase = .standing
                framesInCurrentState = 0
            }

        case .standing:
            if smoothedAngle < squatThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired {
                    phase = .squatting
                    framesInCurrentState = 0
                }
            } else {
                framesInCurrentState = 0
            }

        case .squatting:
            if smoothedAngle > standThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired {
                    phase = .standing
                    repCount += 1
                    framesInCurrentState = 0
                }
            } else {
                framesInCurrentState = 0
            }
        }

        return repCount
    }

    mutating func reset() {
        phase = .unknown
        repCount = 0
        isInPosition = false
        angleHistory = []
        framesInCurrentState = 0
    }

    private func computeKneeAngle(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> Double? {
        // Try right side first, then left
        if let hip = positions[.rightHip],
           let knee = positions[.rightKnee],
           let ankle = positions[.rightAnkle] {
            return PoseDetectionService.angle(at: knee, from: hip, to: ankle)
        }

        if let hip = positions[.leftHip],
           let knee = positions[.leftKnee],
           let ankle = positions[.leftAnkle] {
            return PoseDetectionService.angle(at: knee, from: hip, to: ankle)
        }

        return nil
    }

    private func extractPositions(from observation: VNHumanBodyPoseObservation) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        PoseDetectionService.extractJointPositions(from: observation)
    }
}
