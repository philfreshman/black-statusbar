import AppKit
import Testing
@testable import NightbarCore

@MainActor
struct MenuBarOverlayTests {
    @Test func stripSitsBelowMenuBarUnderbelly() {
        let underbellyLevel = Int(CGWindowLevelForKey(.desktopIconWindow)) + 1

        #expect(MenuBarOverlay.stripLevel.rawValue < underbellyLevel)
    }

    @Test func contrastLayerSitsAboveMenuBarIconsAndBelowMenus() {
        #expect(MenuBarOverlay.contrastLevel > .statusBar)
        #expect(MenuBarOverlay.contrastLevel < .popUpMenu)
    }
}
