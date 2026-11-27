import AppKit
import Testing
@testable import NightbarCore

@MainActor
struct MenuBarOverlayTests {
    @Test func stripSitsAboveMenuBarUnderbelly() {
        let underbellyLevel = Int(CGWindowLevelForKey(.desktopIconWindow)) + 1

        #expect(MenuBarOverlay.stripLevel.rawValue > underbellyLevel)
    }

    @Test func stripSitsBelowAppWindows() {
        #expect(MenuBarOverlay.stripLevel < .normal)
    }
}
