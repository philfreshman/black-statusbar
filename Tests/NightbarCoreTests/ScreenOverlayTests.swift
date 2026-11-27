import AppKit
import Testing

@testable import NightbarCore

@MainActor
struct ScreenOverlayTests {
    @Test func stripSitsBelowMenuBarUnderbelly() {
        let underbellyLevel = Int(CGWindowLevelForKey(.desktopIconWindow)) + 1

        #expect(ScreenOverlay.stripLevel.rawValue < underbellyLevel)
    }

    @Test func contrastLayerSitsAboveMenuBarIconsAndBelowMenus() {
        #expect(ScreenOverlay.contrastLevel > .statusBar)
        #expect(ScreenOverlay.contrastLevel < .popUpMenu)
    }

    /// Transient windows only appear once a swipe ends, so windows of Spaces not shown stay
    /// stationary. Mission Control only hides transient windows.
    @Test func windowsAreTransientOnlyOnTheActiveSpace() {
        #expect(!ScreenOverlay.inactiveSpaceBehavior.contains(.transient))
        #expect(ScreenOverlay.inactiveSpaceBehavior.contains(.stationary))
        #expect(ScreenOverlay.activeSpaceBehavior.contains(.transient))
    }
}
