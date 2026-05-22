import SwiftUI
import AVFoundation
import Vision

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    var joints: PoseDetectionService.JointPositions = [:]

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.updateSkeleton(joints)
    }
}

// AVCaptureVideoPreviewLayer is the backing layer — frame always matches bounds automatically.
final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    private let bonesLayer = CAShapeLayer()
    private let jointsLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeletonLayers()
        observeOrientation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSkeletonLayers()
        observeOrientation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    private func observeOrientation() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func handleOrientationChange() {
        updatePreviewRotation()
    }

    private func updatePreviewRotation() {
        guard let connection = previewLayer.connection else { return }
        let angle = previewRotationAngle(for: UIDevice.current.orientation)
        guard connection.isVideoRotationAngleSupported(angle) else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        connection.videoRotationAngle = angle
        CATransaction.commit()
    }

    private func previewRotationAngle(for orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
        case .landscapeLeft:        return 0
        case .landscapeRight:       return 180
        case .portraitUpsideDown:   return 270
        default:                    return 90
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePreviewRotation()
        bonesLayer.frame = bounds
        jointsLayer.frame = bounds
    }

    private func setupSkeletonLayers() {
        bonesLayer.fillColor = UIColor.clear.cgColor
        bonesLayer.strokeColor = UIColor.systemOrange.withAlphaComponent(0.85).cgColor
        bonesLayer.lineWidth = 2.5
        bonesLayer.lineCap = .round
        layer.addSublayer(bonesLayer)

        jointsLayer.fillColor = UIColor.white.withAlphaComponent(0.9).cgColor
        jointsLayer.strokeColor = UIColor.systemOrange.cgColor
        jointsLayer.lineWidth = 1.5
        layer.addSublayer(jointsLayer)
    }

    func updateSkeleton(_ joints: PoseDetectionService.JointPositions) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }

        guard !joints.isEmpty else {
            bonesLayer.path = nil
            jointsLayer.path = nil
            return
        }

        // Vision: (0,0) = bottom-left. Capture device: (0,0) = top-left.
        // layerPointConverted accounts for videoGravity, rotation, and front-camera mirroring.
        var layerJoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for (name, visionPoint) in joints {
            let devicePoint = CGPoint(x: visionPoint.x, y: 1 - visionPoint.y)
            layerJoints[name] = previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint)
        }

        let bonesPath = UIBezierPath()
        let jointsPath = UIBezierPath()

        let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.leftShoulder, .rightShoulder),
            (.leftShoulder, .leftElbow),  (.leftElbow, .leftWrist),
            (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
            (.leftShoulder, .leftHip),    (.rightShoulder, .rightHip),
            (.leftHip, .rightHip),
            (.leftHip, .leftKnee),        (.leftKnee, .leftAnkle),
            (.rightHip, .rightKnee),      (.rightKnee, .rightAnkle),
            (.nose, .leftShoulder),       (.nose, .rightShoulder),
        ]

        for (from, to) in connections {
            if let p1 = layerJoints[from], let p2 = layerJoints[to] {
                bonesPath.move(to: p1)
                bonesPath.addLine(to: p2)
            }
        }

        let r: CGFloat = 5
        for (_, point) in layerJoints {
            jointsPath.append(UIBezierPath(ovalIn: CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)))
        }

        bonesLayer.path = bonesPath.cgPath
        jointsLayer.path = jointsPath.cgPath
    }
}
