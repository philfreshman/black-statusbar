import AppKit

/// The windows that black out the menu bar of one screen on one Space: a black strip behind the
/// menu bar, a contrast layer over it, and black rounded corners below it.
///
/// The strip sits just above the wallpaper, below desktop icons and windows, so the menu bar
/// looks black and the wallpaper itself stays untouched. On a light wallpaper that is not
/// enough: macOS lays a grey gradient over the strip, and it may draw black text, because it
/// picks the menu bar colours from the wallpaper and ignores windows. So a contrast layer sits
/// over the menu bar and remaps its colours to black with white text (see `ColorRemap`).
///
/// The corners sit above windows, so the screen area below the menu bar looks like a rounded
/// rectangle even when a window fills it. They stay below menus, so menus are never cut off.
///
/// The windows belong to the Space that is active when they are made, so they slide in and out
/// with it when the user swipes between Spaces. Windows that join all Spaces only move to the
/// new Space once the swipe ends, so during it the menu bar would show its own colours.
@MainActor
final class ScreenOverlay {
    /// The window level of the strip: just above the wallpaper.
    ///
    /// macOS keeps a window called "underbelly" one level above the desktop icons. On a light
    /// wallpaper it lays a grey gradient over the menu bar. The strip must stay below it: above
    /// it, the bar would be black under black text, and the contrast layer would turn it all
    /// white. With the strip below, the contrast layer gets black text on grey, which it can
    /// remap to white text on black.
    static let stripLevel = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
    private static let cornerLevel = NSWindow.Level.statusBar
    /// Above the menu bar and its icons, below menus.
    static let contrastLevel = NSWindow.Level(NSWindow.Level.statusBar.rawValue + 1)

    let displayID: CGDirectDisplayID?
    private let strip: NSWindow
    private let contrastLayer: NSWindow?
    private let corners: [NSWindow]

    /// Whether the windows are on the Space their screen shows now.
    var isOnActiveSpace: Bool {
        strip.isOnActiveSpace
    }

    init(screen: NSScreen, cornerRadius: CornerRadius, remap: ColorRemap) {
        displayID = screen.displayID
        strip = Self.makeStrip(for: screen)
        contrastLayer = Self.makeContrastLayer(for: screen, remap: remap)
        corners = Self.makeCorners(for: screen, radius: cornerRadius.points)
    }

    func setRemap(_ remap: ColorRemap) {
        (contrastLayer?.contentView as? ColorRemapView)?.remap = remap
    }

    /// Hides the windows in the opposite order of showing them, so the contrast layer never sits
    /// over a menu bar that has already lost its strip. That would flash for a frame.
    func close() {
        let windowsInHidingOrder = corners + [contrastLayer].compactMap { $0 } + [strip]
        for window in windowsInHidingOrder {
            window.orderOut(nil)
        }
    }

    // MARK: - Making the windows

    private static func makeStrip(for screen: NSScreen) -> NSWindow {
        let strip = makeOverlayWindow(frame: screen.menuBarFrame, level: stripLevel)
        strip.backgroundColor = .black
        strip.isOpaque = true
        strip.orderFrontRegardless()
        return strip
    }

    /// Left out when the menu bar hides automatically: app windows then reach the top of the
    /// screen, and the remap would change their colours.
    private static func makeContrastLayer(for screen: NSScreen, remap: ColorRemap) -> NSWindow? {
        guard screen.reservesSpaceForMenuBar else { return nil }

        let window = makeOverlayWindow(frame: screen.menuBarFrame, level: contrastLevel)
        window.backgroundColor = .clear
        window.isOpaque = false
        let remapView = ColorRemapView(remap: remap)
        remapView.addSubview(makeBottomEdgeCover(width: window.frame.width))
        window.contentView = remapView
        window.orderFrontRegardless()
        return window
    }

    /// A window right below the menu bar draws its dark border into the menu bar's last pixel
    /// row. The remap for a light menu bar would turn that border into a white line, so this
    /// black edge covers it.
    private static func makeBottomEdgeCover(width: CGFloat) -> NSView {
        let cover = NSView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        cover.autoresizingMask = [.width]
        cover.wantsLayer = true
        cover.layer?.backgroundColor = NSColor.black.cgColor
        return cover
    }

    private static func makeCorners(for screen: NSScreen, radius: CGFloat) -> [NSWindow] {
        guard radius > 0 else { return [] }

        return ScreenCorner.allCases.map { corner in
            let frame = corner.frame(
                screenFrame: screen.frame, menuBarHeight: screen.menuBarFrame.height, radius: radius
            )
            let window = makeOverlayWindow(frame: frame, level: cornerLevel)
            window.backgroundColor = .clear
            window.isOpaque = false
            window.contentView = CornerView(corner: corner, radius: radius)
            window.orderFrontRegardless()
            return window
        }
    }

    /// A borderless window that clicks pass through. It stays on the Space where it appears and
    /// keeps out of Mission Control and window cycling. It appears and disappears at once, without
    /// the fade macOS may give new windows.
    private static func makeOverlayWindow(frame: CGRect, level: NSWindow.Level) -> NSWindow {
        let window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.animationBehavior = .none
        window.level = level
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.stationary, .ignoresCycle]
        return window
    }
}
