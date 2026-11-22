import AppKit

extension NSScreen {
    /// Used when the menu bar is set to hide automatically and takes no space on screen.
    private static let standardMenuBarHeight: CGFloat = 24

    /// Height of the menu bar on this screen, in points. Includes the notch area on MacBooks.
    var menuBarHeight: CGFloat {
        let heightReservedByMenuBar = frame.maxY - visibleFrame.maxY
        return max(heightReservedByMenuBar, safeAreaInsets.top, Self.standardMenuBarHeight)
    }

    var menuBarPixelHeight: Int {
        Int((menuBarHeight * backingScaleFactor).rounded(.up))
    }

    var pixelSize: CGSize {
        CGSize(
            width: (frame.width * backingScaleFactor).rounded(),
            height: (frame.height * backingScaleFactor).rounded()
        )
    }
}
