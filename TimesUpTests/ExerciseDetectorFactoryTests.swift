import XCTest
@testable import TimesUp

final class ExerciseDetectorFactoryTests: XCTestCase {

    func test_pushUps_returnsPushUpDetector() {
        XCTAssertTrue(ExerciseDetectorFactory.make(for: .pushUps) is PushUpDetector)
    }

    func test_squats_returnsSquatDetector() {
        XCTAssertTrue(ExerciseDetectorFactory.make(for: .squats) is SquatDetector)
    }

    func test_allExerciseTypes_produceDetectorWithZeroReps() {
        for type in ExerciseType.allCases {
            let detector = ExerciseDetectorFactory.make(for: type)
            XCTAssertEqual(detector.repCount, 0, "\(type) detector should start at 0 reps")
        }
    }

    func test_allExerciseTypes_startNotInPosition() {
        for type in ExerciseType.allCases {
            let detector = ExerciseDetectorFactory.make(for: type)
            XCTAssertFalse(detector.isInPosition, "\(type) detector should start out of position")
        }
    }
}
