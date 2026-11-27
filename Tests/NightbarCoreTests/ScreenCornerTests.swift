import CoreGraphics
import Testing
@testable import NightbarCore

struct ScreenCornerTests {
    private let screen = CGRect(x: 1728, y: -200, width: 2560, height: 1440)
    private let menuBarHeight: CGFloat = 24
    private let radius: CGFloat = 16

    @Test func isOffByDefault() {
        #expect(CornerRadius.standard == .off)
        #expect(CornerRadius.off.points == 0)
    }

    @Test func growsFromLowToHigh() {
        #expect(CornerRadius.low.points < CornerRadius.mid.points)
        #expect(CornerRadius.mid.points < CornerRadius.high.points)
    }

    @Test(arguments: [
        (ScreenCorner.topLeft, CGRect(x: 1728, y: 1200, width: 16, height: 16)),
        (ScreenCorner.topRight, CGRect(x: 4272, y: 1200, width: 16, height: 16)),
        (ScreenCorner.bottomLeft, CGRect(x: 1728, y: -200, width: 16, height: 16)),
        (ScreenCorner.bottomRight, CGRect(x: 4272, y: -200, width: 16, height: 16)),
    ])
    func topCornersHangBelowTheMenuBarAndBottomCornersSitOnTheScreenEdge(corner: ScreenCorner, expected: CGRect) {
        let frame = corner.frame(screenFrame: screen, menuBarHeight: menuBarHeight, radius: radius)

        #expect(frame == expected)
    }

    /// Each pair is a point next to the screen's corner and a point next to the screen's middle.
    @Test(arguments: [
        (ScreenCorner.topLeft, CGPoint(x: 1, y: 15), CGPoint(x: 15, y: 1)),
        (ScreenCorner.topRight, CGPoint(x: 15, y: 15), CGPoint(x: 1, y: 1)),
        (ScreenCorner.bottomLeft, CGPoint(x: 1, y: 1), CGPoint(x: 15, y: 15)),
        (ScreenCorner.bottomRight, CGPoint(x: 15, y: 1), CGPoint(x: 1, y: 15)),
    ])
    func isBlackAtTheScreenCornerAndClearTowardsTheMiddle(corner: ScreenCorner, outer: CGPoint, inner: CGPoint) {
        let shape = corner.blackShape(radius: radius)

        #expect(shape.contains(outer))
        #expect(!shape.contains(inner))
    }

    @Test func followsAQuarterCircle() {
        let shape = ScreenCorner.topLeft.blackShape(radius: radius)

        // The middle of the square is 11.3 points from the circle's centre at (16, 0), so inside it.
        #expect(!shape.contains(CGPoint(x: 8, y: 8)))
        // This point is 16.3 points from the centre, just outside the circle.
        #expect(shape.contains(CGPoint(x: 3, y: 9.5)))
    }
}
