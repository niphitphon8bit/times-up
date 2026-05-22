import AVFoundation
import CoreMedia
import Vision
import Observation

@Observable
final class ChallengeViewModel: NSObject {
    let alarm: Alarm
    var completedReps = 0
    var requiredReps: Int
    var isComplete = false
    var isInPosition = false
    var cameraPermissionDenied = false
    var exerciseType: ExerciseType
    var progress: Double { min(Double(completedReps) / Double(requiredReps), 1.0) }

    private(set) var captureSession = AVCaptureSession()
    private let poseService = PoseDetectionService()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "com.timesup.pose", qos: .userInteractive)
    // Only accessed on processingQueue
    private var exerciseDetector: any ExerciseDetector
    private var frameCount = 0

    init(alarm: Alarm) {
        self.alarm = alarm
        self.requiredReps = alarm.requiredReps
        self.exerciseType = alarm.exerciseType
        self.exerciseDetector = ExerciseDetectorFactory.make(for: alarm.exerciseType)
        super.init()
    }

    func startSession() {
        checkCameraPermission { [weak self] granted in
            guard granted else {
                Task { @MainActor in self?.cameraPermissionDenied = true }
                return
            }
            self?.setupCamera()
        }
        AudioService.shared.startAlarmSound()
    }

    func stopSession() {
        captureSession.stopRunning()
        AudioService.shared.stopAlarmSound()
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    private func setupCamera() {
        captureSession.beginConfiguration()

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
        }

        captureSession.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
}

extension ChallengeViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // frameCount and exerciseDetector are only accessed on processingQueue
        frameCount += 1
        guard frameCount % 3 == 0 else { return }

        guard let observation = poseService.detectPose(in: sampleBuffer) else {
            Task { @MainActor in self.isInPosition = false }
            return
        }

        let reps = exerciseDetector.processObservation(observation)
        let inPosition = exerciseDetector.isInPosition

        Task { @MainActor in
            self.completedReps = reps
            self.isInPosition = inPosition
            if reps >= self.requiredReps && !self.isComplete {
                self.isComplete = true
                self.stopSession()
            }
        }
    }
}
