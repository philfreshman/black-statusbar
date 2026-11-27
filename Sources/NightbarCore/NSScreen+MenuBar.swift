import AppKit

/// Where the menu bar sits on a screen, worked out from the screen's frames so it can be tested without one.
enum MenuBarGeometry {
    /// Used when the menu bar is set to hide automatically and takes no space on screen.
    static let standardHeight: CGFloat = 24

    /// Height of the menu bar in points. Includes the notch area on MacBooks.
    static func height(screenFrame: CGRect, visibleFrame: CGRect, safeAreaTop: CGFloat) -> CGFloat {
        let heightReservedByMenuBar = screenFrame.maxY - visibleFrame.maxY
        return max(heightReservedByMenuBar, safeAreaTop, standardHeight)
    }

    /// Whether the menu bar takes space at the top of the screen, so app windows stay below it.
    /// It takes none when it hides automatically.
    static func reservesSpace(screenFrame: CGRect, visibleFrame: CGRect) -> Bool {
        screenFrame.maxY > visibleFrame.maxY
    }

    /// The band along the top edge of the screen where the menu bar sits.
    static func frame(screenFrame: CGRect, menuBarHeight: CGFloat) -> CGRect {
        CGRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - menuBarHeight,
            width: screenFrame.width,
            height: menuBarHeight
        )
    }
}

extension NSScreen {
    /// The band along the top of the screen where the menu bar sits, notch included.
    var menuBarFrame: CGRect {
        let height = MenuBarGeometry.height(
            screenFrame: frame, visibleFrame: visibleFrame, safeAreaTop: safeAreaInsets.top
        )
        return MenuBarGeometry.frame(screenFrame: frame, menuBarHeight: height)
    }

    /// The Core Graphics ID of the display this screen shows, or nil when macOS does not report one.
    var displayID: CGDirectDisplayID? {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }

    /// Whether the menu bar takes space at the top of the screen. It takes none when it hides automatically.
    var reservesSpaceForMenuBar: Bool {
        MenuBarGeometry.reservesSpace(screenFrame: frame, visibleFrame: visibleFrame)
    }
}
