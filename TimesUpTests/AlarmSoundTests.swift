import XCTest
@testable import TimesUp

final class AlarmSoundTests: XCTestCase {

    // MARK: - Identifiable

    func test_id_equalsRawValue() {
        for sound in AlarmSound.allCases {
            XCTAssertEqual(sound.id, sound.rawValue)
        }
    }

    func test_rawValues_areDistinct() {
        let rawValues = AlarmSound.allCases.map { $0.rawValue }
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }

    // MARK: - Case count

    func test_caseCount_isFour() {
        XCTAssertEqual(AlarmSound.allCases.count, 4)
    }

    // MARK: - Icon

    func test_allCases_haveNonEmptyIcon() {
        for sound in AlarmSound.allCases {
            XCTAssertFalse(sound.icon.isEmpty, "\(sound) has empty icon")
        }
    }

    func test_icons_areDistinctPerType() {
        let icons = AlarmSound.allCases.map { $0.icon }
        XCTAssertEqual(icons.count, Set(icons).count)
    }

    // MARK: - System sound IDs

    func test_allCases_havePositiveSystemSoundID() {
        for sound in AlarmSound.allCases {
            XCTAssertGreaterThan(sound.systemSoundID, 0, "\(sound) has invalid system sound ID")
        }
    }

    func test_classic_systemSoundID() {
        XCTAssertEqual(AlarmSound.classic.systemSoundID, 1005)
    }

    func test_ringtone_systemSoundID() {
        XCTAssertEqual(AlarmSound.ringtone.systemSoundID, 1007)
    }

    func test_digital_systemSoundID() {
        XCTAssertEqual(AlarmSound.digital.systemSoundID, 1022)
    }

    func test_chime_systemSoundID() {
        XCTAssertEqual(AlarmSound.chime.systemSoundID, 1016)
    }

    // MARK: - System sound IDs are distinct

    func test_systemSoundIDs_areDistinct() {
        let ids = AlarmSound.allCases.map { $0.systemSoundID }
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}
