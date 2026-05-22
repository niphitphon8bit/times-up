import XCTest
@testable import TimesUp

// Smoothing window = 5 frames. Angle history from the prior phase bleeds into
// the next, so transitions need extra frames to flush the window:
//   .unknown → .up : 1 frame at 180° (immediate from .unknown)
//   .up → .down    : 4 frames at 30°  (3 below threshold + 1 to flush 180°)
//   .down → .up    : 7 frames at 180° (4 to flush + 3 to hold > 150°)
//
// One full rep = 1 + 4 + 7 = 12 processAngle calls.
final class PushUpDetectorTests: XCTestCase {
    private func feed(_ angle: Double, into detector: inout PushUpDetector, times: Int) {
        for _ in 0..<times { _ = detector.processAngle(angle) }
    }

    func test_noJoints_isNotInPosition() {
        var d = PushUpDetector()
        XCTAssertFalse(d.isInPosition)
        XCTAssertEqual(d.repCount, 0)
    }

    func test_reset_clearsAllState() {
        var d = PushUpDetector()
        feed(180, into: &d, times: 1)
        feed(30,  into: &d, times: 4)
        feed(180, into: &d, times: 7)
        XCTAssertEqual(d.repCount, 1)
        d.reset()
        XCTAssertEqual(d.repCount, 0)
        XCTAssertFalse(d.isInPosition)
    }

    func test_oneFullRep_counts() {
        var d = PushUpDetector()
        feed(180, into: &d, times: 1)   // → .up
        feed(30,  into: &d, times: 4)   // → .down
        feed(180, into: &d, times: 7)   // → .up + rep counted
        XCTAssertEqual(d.repCount, 1)
    }

    func test_twoFullReps_countsTwo() {
        var d = PushUpDetector()
        feed(180, into: &d, times: 1)
        feed(30,  into: &d, times: 7)   // 7 covers worst-case flush when history is all-up
        feed(180, into: &d, times: 7)
        feed(30,  into: &d, times: 7)
        feed(180, into: &d, times: 7)
        XCTAssertEqual(d.repCount, 2)
    }

    func test_holdNotComplete_doesNotCount() {
        var d = PushUpDetector()
        feed(180, into: &d, times: 1)
        feed(30,  into: &d, times: 4)
        // 6 frames up — one short of the 7 needed
        feed(180, into: &d, times: 6)
        XCTAssertEqual(d.repCount, 0)
        // completing the 7th frame tips it over
        feed(180, into: &d, times: 1)
        XCTAssertEqual(d.repCount, 1)
    }
}
