import CoreGraphics
import Foundation

/// Tells whether a screen shows an app in full screen, on a Space of its own.
///
/// Nightbar leaves those Spaces alone: a window it made there would cover the top of the app.
enum FullScreenDetection {
    /// An app in full screen has a window that covers the whole display, menu bar area
    /// included. Other app windows stop below the menu bar.
    static func showsFullScreenWindow(displayBounds: CGRect, appWindowBounds: [CGRect]) -> Bool {
        appWindowBounds.contains { $0.contains(displayBounds) }
    }

    static func showsFullScreenWindow(on displayID: CGDirectDisplayID?) -> Bool {
        guard let displayID else { return false }
        return showsFullScreenWindow(
            displayBounds: CGDisplayBounds(displayID), appWindowBounds: onScreenAppWindowBounds())
    }

    /// The bounds of the app windows on screen, at the normal window level, in display coordinates.
    private static func onScreenAppWindowBounds() -> [CGRect] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        return
            windows
            .filter { $0[kCGWindowLayer as String] as? Int == Int(CGWindowLevelForKey(.normalWindow)) }
            .compactMap { $0[kCGWindowBounds as String] as? NSDictionary }
            .compactMap { CGRect(dictionaryRepresentation: $0 as CFDictionary) }
    }
}
