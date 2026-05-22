import SwiftUI

struct ChallengeView: View {
    @State private var viewModel: ChallengeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEmergencyDismiss = false

    init(alarm: Alarm) {
        _viewModel = State(initialValue: ChallengeViewModel(alarm: alarm))
    }

    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 16) {
                    if !viewModel.isInPosition {
                        Label(viewModel.exerciseType.instruction, systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }

                    Text(viewModel.exerciseType.rawValue)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: viewModel.progress)

                        VStack(spacing: 4) {
                            Text("\(viewModel.completedReps)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                                .animation(.spring, value: viewModel.completedReps)
                            Text("of \(viewModel.requiredReps)")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 150, height: 150)

                    Image(systemName: viewModel.exerciseType.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                }
                .padding(32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .padding(.bottom, 60)
            }

            if viewModel.cameraPermissionDenied {
                cameraPermissionOverlay
            }

            if viewModel.isComplete {
                completionOverlay
            }
        }
        .onAppear { viewModel.startSession() }
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        }
    }
}
