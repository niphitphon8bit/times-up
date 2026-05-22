import Vision

struct PushUpDetector: ExerciseDetector {
    private enum Phase { case unknown, up, down }

    private var phase: Phase = .unknown
    private(set) var repCount = 0
    private(set) var isInPosition = false
    private var angleHistory: [Double] = []
    private let smoothingWindow = 5
    private let downThreshold: Double = 90
    private let upThreshold: Double = 150
    private let holdFramesRequired = 3
    private var framesInCurrentState = 0

    mutating func processObservation(_ observation: VNHumanBodyPoseObservation) -> Int {
        let positions = extractPositions(from: observation)

        guard let elbowAngle = computeElbowAngle(positions: positions) else {
            isInPosition = false
            return repCount
        }

        isInPosition = true
        angleHistory.append(elbowAngle)
        if angleHistory.count > smoothingWindow {
            angleHistory.removeFirst()
        }

        let smoothedAngle = angleHistory.reduce(0, +) / Double(angleHistory.count)

        switch phase {
        case .unknown:
            if smoothedAngle > upThreshold {
                phase = .up
                framesInCurrentState = 0
            } else if smoothedAngle < downThreshold {
                phase = .down
                framesInCurrentState = 0
            }

        case .up:
            if smoothedAngle < downThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired {
                    phase = .down
                    framesInCurrentState = 0
                }
            } else {
                framesInCurrentState = 0
            }

        case .down:
            if smoothedAngle > upThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired {
                    phase = .up
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

    private func computeElbowAngle(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> Double? {
        // Try right side first, then left
        if let shoulder = positions[.rightShoulder],
           let elbow = positions[.rightElbow],
           let wrist = positions[.rightWrist] {
            return PoseDetectionService.angle(at: elbow, from: shoulder, to: wrist)
        }

        if let shoulder = positions[.leftShoulder],
           let elbow = positions[.leftElbow],
           let wrist = positions[.leftWrist] {
            return PoseDetectionService.angle(at: elbow, from: shoulder, to: wrist)
        }

        return nil
    }

    private func extractPositions(from observation: VNHumanBodyPoseObservation) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        PoseDetectionService.extractJointPositions(from: observation)
    }
}
