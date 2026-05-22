import XCTest
@testable import TimesUp

final class ExerciseTypeTests: XCTestCase {

    // MARK: - Identifiable

    func test_id_equalsRawValue() {
        for type in ExerciseType.allCases {
            XCTAssertEqual(type.id, type.rawValue)
        }
    }

    func test_rawValues_areDistinct() {
        let rawValues = ExerciseType.allCases.map { $0.rawValue }
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }

    // MARK: - View support: icon

    func test_allCases_haveNonEmptyIcon() {
        for type in ExerciseType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type) has empty icon")
        }
    }

    func test_pushUps_icon() {
        XCTAssertEqual(ExerciseType.pushUps.icon, "figure.core.training")
    }

    func test_squats_icon() {
        XCTAssertEqual(ExerciseType.squats.icon, "figure.strengthtraining.functional")
    }

    func test_icons_areDistinctPerType() {
        let icons = ExerciseType.allCases.map { $0.icon }
        XCTAssertEqual(icons.count, Set(icons).count)
    }

    // MARK: - View support: instruction

    func test_allCases_haveNonEmptyInstruction() {
        for type in ExerciseType.allCases {
            XCTAssertFalse(type.instruction.isEmpty, "\(type) has empty instruction")
        }
    }

    func test_pushUps_instruction_mentionesSide() {
        XCTAssertTrue(ExerciseType.pushUps.instruction.lowercased().contains("side"))
    }

    func test_squats_instruction_mentionsFront() {
        XCTAssertTrue(ExerciseType.squats.instruction.lowercased().contains("front"))
    }

    func test_instructions_areDistinctPerType() {
        let instructions = ExerciseType.allCases.map { $0.instruction }
        XCTAssertEqual(instructions.count, Set(instructions).count)
    }
}
