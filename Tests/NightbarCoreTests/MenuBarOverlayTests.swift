import AppKit
import Testing
@testable import NightbarCore

@MainActor
struct MenuBarOverlayTests {
    @Test func stripSitsBelowMenuBarUnderbelly() {
        let underbellyLevel = Int(CGWindowLevelForKey(.desktopIconWindow)) + 1

        #expect(ScreenOverlay.stripLevel.rawValue < underbellyLevel)
    }

    @Test func contrastLayerSitsAboveMenuBarIconsAndBelowMenus() {
        #expect(ScreenOverlay.contrastLevel > .statusBar)
        #expect(ScreenOverlay.contrastLevel < .popUpMenu)
    }
}
