import XCTest
@testable import TimesUp

// Smoothing window = 5 frames. Metric is the hip-drop ratio (Vision y, increases upward).
// Transitions from .unknown only go to .standing:
//   .unknown → .standing  : 1 frame  at 1.0  (above standThreshold 0.85)
//   .standing → .squatting: 4 frames at 0.0  (1 flush above squatThreshold + 3 hold)
//   .squatting → .standing: 7 frames at 1.0  (4 flush below standThreshold + 3 hold)
//
// One full squat rep = 1 + 4 + 7 = 12 processMetric calls.
final class SquatDetectorTests: XCTestCase {
    private func feed(_ ratio: Double, into detector: inout SquatDetector, times: Int) {
        for _ in 0..<times { _ = detector.processMetric(ratio) }
    }

    func test_noInput_isNotInPosition() {
        var d = SquatDetector()
        XCTAssertFalse(d.isInPosition)
        XCTAssertEqual(d.repCount, 0)
    }

    func test_reset_clearsAllState() {
        var d = SquatDetector()
        feed(1.0, into: &d, times: 1)
        feed(0.0, into: &d, times: 4)
        feed(1.0, into: &d, times: 7)
        XCTAssertEqual(d.repCount, 1)
        d.reset()
        XCTAssertEqual(d.repCount, 0)
        XCTAssertFalse(d.isInPosition)
    }

    func test_oneFullRep_counts() {
        var d = SquatDetector()
        feed(1.0, into: &d, times: 1)   // → .standing
        feed(0.0, into: &d, times: 4)   // → .squatting
        feed(1.0, into: &d, times: 7)   // → .standing + rep counted
        XCTAssertEqual(d.repCount, 1)
    }

    func test_twoFullReps_countsTwo() {
        var d = SquatDetector()
        feed(1.0, into: &d, times: 1)
        feed(0.0, into: &d, times: 7)   // 7 covers worst-case flush when history is all-standing
        feed(1.0, into: &d, times: 7)
        feed(0.0, into: &d, times: 7)
        feed(1.0, into: &d, times: 7)
        XCTAssertEqual(d.repCount, 2)
    }

    func test_holdNotComplete_doesNotCount() {
        var d = SquatDetector()
        feed(1.0, into: &d, times: 1)
        feed(0.0, into: &d, times: 4)
        feed(1.0, into: &d, times: 6)
        XCTAssertEqual(d.repCount, 0)
        feed(1.0, into: &d, times: 1)
        XCTAssertEqual(d.repCount, 1)
    }

    func test_squatRatioInUnknown_staysUnknown() {
        // SquatDetector ignores low ratios in .unknown — only standing triggers transition
        var d = SquatDetector()
        feed(0.0, into: &d, times: 10)
        XCTAssertEqual(d.repCount, 0)
    }
}
