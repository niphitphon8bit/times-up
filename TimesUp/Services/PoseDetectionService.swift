import Vision
import CoreMedia
import CoreGraphics

final class PoseDetectionService {
    typealias JointPositions = [VNHumanBodyPoseObservation.JointName: CGPoint]

    func detectPose(in sampleBuffer: CMSampleBuffer) -> VNHumanBodyPoseObservation? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right,
            options: [:]
        )

        do {
            try handler.perform([request])
            return request.results?.first
        } catch {
            return nil
        }
    }

    static func extractJointPositions(
        from observation: VNHumanBodyPoseObservation,
        minimumConfidence: Float = 0.15
    ) -> JointPositions {
        var positions: JointPositions = [:]

        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .nose,
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]

        for jointName in jointNames {
            guard let point = try? observation.recognizedPoint(jointName),
                  point.confidence > minimumConfidence else { continue }
            positions[jointName] = point.location
        }

        return positions
    }

    static func angle(at center: CGPoint, from pointA: CGPoint, to pointB: CGPoint) -> Double {
        let vectorA = CGVector(dx: pointA.x - center.x, dy: pointA.y - center.y)
        let vectorB = CGVector(dx: pointB.x - center.x, dy: pointB.y - center.y)
        let dotProduct = vectorA.dx * vectorB.dx + vectorA.dy * vectorB.dy
        let magnitudeA = sqrt(vectorA.dx * vectorA.dx + vectorA.dy * vectorA.dy)
        let magnitudeB = sqrt(vectorB.dx * vectorB.dx + vectorB.dy * vectorB.dy)
        guard magnitudeA > 0, magnitudeB > 0 else { return 0 }
        let cosAngle = dotProduct / (magnitudeA * magnitudeB)
        return acos(min(max(cosAngle, -1.0), 1.0)) * 180.0 / .pi
    }
}
