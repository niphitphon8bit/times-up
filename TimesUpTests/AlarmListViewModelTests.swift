import XCTest
import SwiftData
@testable import TimesUp

final class AlarmListViewModelTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Alarm.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    private func makeVM() -> AlarmListViewModel {
        AlarmListViewModel(modelContext: context)
    }

    private func fetchAll() throws -> [Alarm] {
        try context.fetch(FetchDescriptor<Alarm>())
    }

    // MARK: - addAlarm

    func test_addAlarm_insertsOneRecord() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        XCTAssertEqual(try fetchAll().count, 1)
    }

    func test_addAlarm_storesExerciseType() throws {
        makeVM().addAlarm(time: .now, exerciseType: .squats, requiredReps: 10, label: "Test")
        XCTAssertEqual(try fetchAll().first?.exerciseType, .squats)
    }

    func test_addAlarm_storesRequiredReps() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 25, label: "Test")
        XCTAssertEqual(try fetchAll().first?.requiredReps, 25)
    }

    func test_addAlarm_storesLabel() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Morning")
        XCTAssertEqual(try fetchAll().first?.label, "Morning")
    }

    func test_addAlarm_storesTime() throws {
        let time = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: .now)!
        makeVM().addAlarm(time: time, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        XCTAssertEqual(try fetchAll().first?.time, time)
    }

    func test_addAlarm_isEnabledByDefault() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        XCTAssertTrue(try XCTUnwrap(fetchAll().first).isEnabled)
    }

    func test_addMultipleAlarms_allPersist() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "A")
        makeVM().addAlarm(time: .now, exerciseType: .squats, requiredReps: 20, label: "B")
        XCTAssertEqual(try fetchAll().count, 2)
    }

    func test_addAlarm_storesSound() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test", sound: .chime)
        XCTAssertEqual(try fetchAll().first?.sound, .chime)
    }

    // MARK: - deleteAlarm

    func test_deleteAlarm_removesRecord() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        let alarm = try XCTUnwrap(fetchAll().first)
        makeVM().deleteAlarm(alarm)
        XCTAssertEqual(try fetchAll().count, 0)
    }

    func test_deleteAlarm_removesCorrectRecord() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Keep")
        makeVM().addAlarm(time: .now, exerciseType: .squats, requiredReps: 20, label: "Delete")
        let toDelete = try XCTUnwrap(fetchAll().first(where: { $0.label == "Delete" }))
        makeVM().deleteAlarm(toDelete)
        let remaining = try fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.label, "Keep")
    }

    // MARK: - toggleAlarm

    func test_toggleAlarm_disablesEnabledAlarm() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        let alarm = try XCTUnwrap(fetchAll().first)
        XCTAssertTrue(alarm.isEnabled)
        makeVM().toggleAlarm(alarm)
        XCTAssertFalse(alarm.isEnabled)
    }

    func test_toggleAlarm_enablesDisabledAlarm() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        let alarm = try XCTUnwrap(fetchAll().first)
        makeVM().toggleAlarm(alarm) // disable
        makeVM().toggleAlarm(alarm) // re-enable
        XCTAssertTrue(alarm.isEnabled)
    }

    func test_toggleAlarm_persistsChange() throws {
        makeVM().addAlarm(time: .now, exerciseType: .pushUps, requiredReps: 10, label: "Test")
        let alarm = try XCTUnwrap(fetchAll().first)
        makeVM().toggleAlarm(alarm)
        // Re-fetch to confirm the change was saved
        let refetched = try XCTUnwrap(fetchAll().first)
        XCTAssertFalse(refetched.isEnabled)
    }
}
