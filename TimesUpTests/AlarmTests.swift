import XCTest
@testable import TimesUp

final class AlarmTests: XCTestCase {

    // MARK: - Defaults

    func test_defaultInit_isEnabled() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertTrue(alarm.isEnabled)
    }

    func test_defaultInit_repsIsTen() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertEqual(alarm.requiredReps, 10)
    }

    func test_defaultInit_labelIsAlarm() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertEqual(alarm.label, "Alarm")
    }

    func test_customInit_storesAllProperties() {
        let time = Date(timeIntervalSince1970: 0)
        let alarm = Alarm(time: time, exerciseType: .squats, requiredReps: 20, label: "Gym")
        XCTAssertEqual(alarm.time, time)
        XCTAssertEqual(alarm.exerciseType, .squats)
        XCTAssertEqual(alarm.requiredReps, 20)
        XCTAssertEqual(alarm.label, "Gym")
    }

    // MARK: - Notification identifier

    func test_notificationIdentifier_matchesUUID() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertEqual(alarm.notificationIdentifier, alarm.id.uuidString)
    }

    func test_notificationIdentifier_isUniquePerAlarm() {
        let a = Alarm(time: .now, exerciseType: .pushUps)
        let b = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertNotEqual(a.notificationIdentifier, b.notificationIdentifier)
    }

    // MARK: - exerciseType computed property

    func test_exerciseType_roundtripsAllCases() {
        for type in ExerciseType.allCases {
            let alarm = Alarm(time: .now, exerciseType: type)
            XCTAssertEqual(alarm.exerciseType, type)
        }
    }

    func test_exerciseType_defaultsToPushUps_forUnknownRaw() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        alarm.exerciseTypeRaw = "invalid_value"
        XCTAssertEqual(alarm.exerciseType, .pushUps)
    }

    func test_exerciseType_setter_updatesRaw() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        alarm.exerciseType = .squats
        XCTAssertEqual(alarm.exerciseTypeRaw, ExerciseType.squats.rawValue)
    }

    // MARK: - sound

    func test_defaultSound_isClassic() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertEqual(alarm.sound, .classic)
    }

    func test_sound_roundtripsAllCases() {
        for sound in AlarmSound.allCases {
            let alarm = Alarm(time: .now, exerciseType: .pushUps, sound: sound)
            XCTAssertEqual(alarm.sound, sound, "Sound roundtrip failed for \(sound)")
        }
    }

    func test_soundRaw_matchesSoundRawValue() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps, sound: .chime)
        XCTAssertEqual(alarm.soundRaw, AlarmSound.chime.rawValue)
    }

    func test_sound_setter_updatesRaw() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps, sound: .classic)
        alarm.sound = .digital
        XCTAssertEqual(alarm.soundRaw, AlarmSound.digital.rawValue)
    }

    func test_sound_withInvalidRawValue_fallsBackToClassic() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        alarm.soundRaw = "nonexistent"
        XCTAssertEqual(alarm.sound, .classic)
    }

    // MARK: - timeString

    func test_timeString_isNonEmpty() {
        let alarm = Alarm(time: .now, exerciseType: .pushUps)
        XCTAssertFalse(alarm.timeString.isEmpty)
    }

    func test_timeString_differsForDifferentTimes() {
        let morning = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: .now)!
        let evening = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: .now)!
        let alarmA = Alarm(time: morning, exerciseType: .pushUps)
        let alarmB = Alarm(time: evening, exerciseType: .pushUps)
        XCTAssertNotEqual(alarmA.timeString, alarmB.timeString)
    }

    func test_timeString_matchesDateFormatterShortStyle() {
        let time = Date(timeIntervalSince1970: 28800) // 08:00 UTC
        let alarm = Alarm(time: time, exerciseType: .pushUps)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        XCTAssertEqual(alarm.timeString, formatter.string(from: time))
    }
}
