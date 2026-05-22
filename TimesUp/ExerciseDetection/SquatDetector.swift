import Vision

struct SquatDetector: ExerciseDetector {
    private enum Phase { case unknown, standing, squatting }

    private var phase: Phase = .unknown
    private(set) var repCount = 0
    private(set) var isInPosition = false
    private var metricHistory: [Double] = []
    private let smoothingWindow = 5
    // hip-drop ratio: (hip.y - knee.y) / (knee.y - ankle.y) in Vision coords (y increases upward)
    // Standing ≈ 1.0 (hip well above knee); squatting ≈ 0 or negative (hip near/below knee).
    private let squatThreshold: Double = 0.35
    private let standThreshold: Double = 0.85
    private let holdFramesRequired = 3
    private var framesInCurrentState = 0

    mutating func processObservation(_ observation: VNHumanBodyPoseObservation) -> Int {
        let positions = PoseDetectionService.extractJointPositions(from: observation)
        guard let metric = computeHipDropRatio(positions: positions) else {
            isInPosition = false
            return repCount
        }
        isInPosition = true
        return processMetric(metric)
    }

    mutating func processMetric(_ ratio: Double) -> Int {
        metricHistory.append(ratio)
        if metricHistory.count > smoothingWindow { metricHistory.removeFirst() }
        let smoothed = metricHistory.reduce(0, +) / Double(metricHistory.count)

        switch phase {
        case .unknown:
            if smoothed > standThreshold { phase = .standing; framesInCurrentState = 0 }

        case .standing:
            if smoothed < squatThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired { phase = .squatting; framesInCurrentState = 0 }
            } else { framesInCurrentState = 0 }

        case .squatting:
            if smoothed > standThreshold {
                framesInCurrentState += 1
                if framesInCurrentState >= holdFramesRequired { phase = .standing; repCount += 1; framesInCurrentState = 0 }
            } else { framesInCurrentState = 0 }
        }

        return repCount
    }

    mutating func reset() {
        phase = .unknown
        repCount = 0
        isInPosition = false
        metricHistory = []
        framesInCurrentState = 0
    }

    // Averages the hip-drop ratio across both legs when both are visible.
    private func computeHipDropRatio(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) -> Double? {
        typealias JN = VNHumanBodyPoseObservation.JointName
        var ratios: [Double] = []

        let sides: [(JN, JN, JN)] = [
            (.rightHip, .rightKnee, .rightAnkle),
            (.leftHip,  .leftKnee,  .leftAnkle)
        ]

        for (hipKey, kneeKey, ankleKey) in sides {
            guard let hip   = positions[hipKey],
                  let knee  = positions[kneeKey],
                  let ankle = positions[ankleKey] else { continue }
            let lowerLeg = knee.y - ankle.y
            guard lowerLeg > 0.01 else { continue }
            ratios.append((hip.y - knee.y) / lowerLeg)
        }

        guard !ratios.isEmpty else { return nil }
        return ratios.reduce(0, +) / Double(ratios.count)
    }
}
