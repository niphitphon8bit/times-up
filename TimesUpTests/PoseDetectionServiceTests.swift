import XCTest
@testable import TimesUp

final class PoseDetectionServiceTests: XCTestCase {
    func test_rightAngle() {
        let angle = PoseDetectionService.angle(
            at: CGPoint(x: 0, y: 0),
            from: CGPoint(x: 1, y: 0),
            to: CGPoint(x: 0, y: 1)
        )
        XCTAssertEqual(angle, 90.0, accuracy: 0.001)
    }

    func test_straightLine() {
        let angle = PoseDetectionService.angle(
            at: CGPoint(x: 0, y: 0),
            from: CGPoint(x: 1, y: 0),
            to: CGPoint(x: -1, y: 0)
        )
        XCTAssertEqual(angle, 180.0, accuracy: 0.001)
    }

    func test_coincidentPoints_returnsZero() {
        let angle = PoseDetectionService.angle(
            at: CGPoint(x: 0, y: 0),
            from: CGPoint(x: 1, y: 0),
            to: CGPoint(x: 1, y: 0)
        )
        XCTAssertEqual(angle, 0.0, accuracy: 0.001)
    }

    func test_zeroLengthVector_returnsZero() {
        // pointA == center → zero-length vector → guard fires → returns 0
        let center = CGPoint(x: 0, y: 0)
        let angle = PoseDetectionService.angle(at: center, from: center, to: CGPoint(x: 1, y: 0))
        XCTAssertEqual(angle, 0.0)
    }

    func test_acuteAngle() {
        // 45° angle
        let angle = PoseDetectionService.angle(
            at: CGPoint(x: 0, y: 0),
            from: CGPoint(x: 1, y: 0),
            to: CGPoint(x: 1, y: 1)
        )
        XCTAssertEqual(angle, 45.0, accuracy: 0.001)
    }
}
