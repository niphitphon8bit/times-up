import XCTest
@testable import TimesUp

final class AppStateTests: XCTestCase {

    func test_initialPendingAlarmId_isNil() {
        XCTAssertNil(AppState().pendingAlarmId)
    }

    func test_setPendingAlarmId() {
        let state = AppState()
        state.pendingAlarmId = "alarm-123"
        XCTAssertEqual(state.pendingAlarmId, "alarm-123")
    }

    func test_clearPendingAlarmId() {
        let state = AppState()
        state.pendingAlarmId = "alarm-123"
        state.pendingAlarmId = nil
        XCTAssertNil(state.pendingAlarmId)
    }

    func test_overwritePendingAlarmId() {
        let state = AppState()
        state.pendingAlarmId = "first"
        state.pendingAlarmId = "second"
        XCTAssertEqual(state.pendingAlarmId, "second")
    }
}
