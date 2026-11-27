import CoreGraphics
import Testing
@testable import NightbarCore

struct MenuBarGeometryTests {
    private let screen = CGRect(x: 0, y: 0, width: 1728, height: 1117)

    @Test func usesHeightReservedByMenuBar() {
        let visible = CGRect(x: 0, y: 0, width: 1728, height: 1080)

        let height = MenuBarGeometry.height(screenFrame: screen, visibleFrame: visible, safeAreaTop: 32)

        #expect(height == 37)
    }

    @Test func usesNotchHeightWhenLarger() {
        let visible = CGRect(x: 0, y: 0, width: 1728, height: 1093)

        let height = MenuBarGeometry.height(screenFrame: screen, visibleFrame: visible, safeAreaTop: 32)

        #expect(height == 32)
    }

    @Test func fallsBackToStandardHeightWhenMenuBarHides() {
        let height = MenuBarGeometry.height(screenFrame: screen, visibleFrame: screen, safeAreaTop: 0)

        #expect(height == MenuBarGeometry.standardHeight)
    }

    @Test func frameSitsAlongTopEdgeOfScreen() {
        let secondScreen = CGRect(x: 1728, y: -200, width: 2560, height: 1440)

        let frame = MenuBarGeometry.frame(screenFrame: secondScreen, menuBarHeight: 24)

        #expect(frame == CGRect(x: 1728, y: 1216, width: 2560, height: 24))
    }

    @Test func menuBarReservesSpaceWhenItStaysVisible() {
        let visible = CGRect(x: 0, y: 0, width: 1728, height: 1084)

        #expect(MenuBarGeometry.reservesSpace(screenFrame: screen, visibleFrame: visible))
    }

    @Test func menuBarReservesNoSpaceWhenItHides() {
        let visible = CGRect(x: 0, y: 80, width: 1728, height: 1037)

        #expect(!MenuBarGeometry.reservesSpace(screenFrame: screen, visibleFrame: visible))
    }
}
