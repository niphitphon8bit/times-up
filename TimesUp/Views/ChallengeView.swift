import SwiftUI

struct ChallengeView: View {
    @State private var viewModel: ChallengeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEmergencyDismiss = false
    @State private var isPositioning = true
    @State private var iconPulse = false
    @State private var arrowPulse = false

    init(alarm: Alarm) {
        _viewModel = State(initialValue: ChallengeViewModel(alarm: alarm))
    }

    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession, joints: viewModel.detectedJoints)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Compact top HUD — leaves the full camera visible
                HStack(alignment: .center) {
                    Label(viewModel.exerciseType.rawValue, systemImage: viewModel.exerciseType.icon)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())

                    Spacer()

                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.25), lineWidth: 5)
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(.orange, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                            Text("\(viewModel.completedReps)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                                .animation(.spring, value: viewModel.completedReps)
                        }
                        .frame(width: 64, height: 64)

                        Text("of \(viewModel.requiredReps)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Instruction banner — only visible when pose is lost
                if !viewModel.isInPosition {
                    Label(viewModel.exerciseType.instruction, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isInPosition)

            if viewModel.cameraPermissionDenied {
                cameraPermissionOverlay
            }

            if viewModel.cameraSetupFailed {
                cameraSetupFailedOverlay
            }

            if viewModel.isComplete {
                completionOverlay
            }

            if isPositioning {
                positioningOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .onAppear { viewModel.startAlarmSound() }
        .onDisappear { viewModel.stopSession() }
        .onLongPressGesture(minimumDuration: 10) {
            showEmergencyDismiss = true
        }
        .alert("Emergency Dismiss", isPresented: $showEmergencyDismiss) {
            Button("Dismiss Alarm", role: .destructive) {
                viewModel.stopSession()
                dismiss()
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Are you sure you want to skip the exercise?")
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - Positioning overlay

    private var positioningOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Before You Start")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Position your phone as shown below")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer().frame(height: 44)

                positionDiagram

                Spacer().frame(height: 28)

                Text(viewModel.exerciseType.instruction)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isPositioning = false
                    }
                    viewModel.startSession()
                } label: {
                    Label("I'm Ready!", systemImage: "bolt.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal, 32)
                .padding(.bottom, 52)
            }
        }
    }

    private var positionDiagram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .frame(height: 180)
                .padding(.horizontal, 32)

            if viewModel.exerciseType == .pushUps {
                exerciseDiagramContent(
                    icon: "figure.core.training",
                    phoneLabel: "Phone, to your side",
                    rotatePhone: true
                )
            } else {
                exerciseDiagramContent(
                    icon: "figure.strengthtraining.functional",
                    phoneLabel: "Phone, in front",
                    rotatePhone: false
                )
            }
        }
        .onAppear {
            iconPulse = true
            arrowPulse = true
        }
    }

    private func exerciseDiagramContent(icon: String, phoneLabel: String, rotatePhone: Bool) -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
                    .scaleEffect(iconPulse ? 1.07 : 0.93)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: iconPulse)
                Text("You")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.5))
            }

            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(arrowPulse ? Double(i + 1) * 0.33 : Double(3 - i) * 0.33)
                        .animation(
                            .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                            value: arrowPulse
                        )
                }
            }

            VStack(spacing: 6) {
                Image(systemName: "iphone")
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.8))
                    .rotationEffect(.degrees(rotatePhone ? 90 : 0))
                Text(phoneLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Error / completion overlays

    private var cameraPermissionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                Text("Camera Access Required")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Open Settings and enable camera access to detect exercises.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(32)
        }
    }

    private var cameraSetupFailedOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
                Text("Camera Unavailable")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Could not start the camera. Try closing other apps using the camera, then reopen this alarm.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                Text("Great Job!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("You completed \(viewModel.completedReps) \(viewModel.exerciseType.rawValue)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .transition(.scale.combined(with: .opacity))
        }
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            dismiss()
        }
    }
}
