import XCTest
@testable import TimesUp

// ChallengeViewModel.init touches no AVFoundation or AudioService — safe to construct in tests.
// startSession() does; do not call it here.
final class ChallengeViewModelTests: XCTestCase {
    private func makeAlarm(reps: Int = 10, type: ExerciseType = .pushUps) -> Alarm {
        Alarm(time: .now, exerciseType: type, requiredReps: reps)
    }

    // MARK: - Initial state

    func test_initialDetectedJoints_isEmpty() {
        XCTAssertTrue(ChallengeViewModel(alarm: makeAlarm()).detectedJoints.isEmpty)
    }

    func test_initialCompletedReps_isZero() {
        XCTAssertEqual(ChallengeViewModel(alarm: makeAlarm()).completedReps, 0)
    }

    func test_initialIsComplete_isFalse() {
        XCTAssertFalse(ChallengeViewModel(alarm: makeAlarm()).isComplete)
    }

    func test_initialIsInPosition_isFalse() {
        XCTAssertFalse(ChallengeViewModel(alarm: makeAlarm()).isInPosition)
    }

    func test_initialCameraPermissionDenied_isFalse() {
        XCTAssertFalse(ChallengeViewModel(alarm: makeAlarm()).cameraPermissionDenied)
    }

    func test_initialCameraSetupFailed_isFalse() {
        XCTAssertFalse(ChallengeViewModel(alarm: makeAlarm()).cameraSetupFailed)
    }

    // MARK: - Properties from alarm

    func test_requiredReps_matchesAlarm() {
        XCTAssertEqual(ChallengeViewModel(alarm: makeAlarm(reps: 20)).requiredReps, 20)
    }

    func test_exerciseType_matchesAlarm() {
        XCTAssertEqual(ChallengeViewModel(alarm: makeAlarm(type: .squats)).exerciseType, .squats)
    }

    // MARK: - progress

    func test_progress_isZeroWithNoReps() {
        XCTAssertEqual(ChallengeViewModel(alarm: makeAlarm(reps: 10)).progress, 0.0, accuracy: 0.001)
    }

    func test_progress_isHalfwayAtHalfReps() {
        let vm = ChallengeViewModel(alarm: makeAlarm(reps: 10))
        vm.completedReps = 5
        XCTAssertEqual(vm.progress, 0.5, accuracy: 0.001)
    }

    func test_progress_isOneAtRequiredReps() {
        let vm = ChallengeViewModel(alarm: makeAlarm(reps: 10))
        vm.completedReps = 10
        XCTAssertEqual(vm.progress, 1.0, accuracy: 0.001)
    }

    func test_progress_capsAtOneWhenOverRequiredReps() {
        let vm = ChallengeViewModel(alarm: makeAlarm(reps: 10))
        vm.completedReps = 15
        XCTAssertEqual(vm.progress, 1.0, accuracy: 0.001)
    }

    func test_progress_handlesOneRep() {
        let vm = ChallengeViewModel(alarm: makeAlarm(reps: 1))
        vm.completedReps = 1
        XCTAssertEqual(vm.progress, 1.0, accuracy: 0.001)
    }
}
