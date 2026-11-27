import AppKit

/// Puts a black strip behind the menu bar of every screen, a contrast layer over it, and black
/// rounded corners below it.
///
/// The strip sits just above the wallpaper, below desktop icons and windows, so the menu bar
/// looks black and the wallpaper itself stays untouched. On a light wallpaper that is not
/// enough: macOS lays a grey gradient over the strip, and it may draw black text, because it
/// picks the menu bar colours from the wallpaper and ignores windows. So a contrast layer sits
/// over the menu bar and remaps its colours to black with white text (see `ColorRemap`).
///
/// The corners sit above windows, so the screen area below the menu bar looks like a rounded
/// rectangle even when a window fills it. They stay below menus, so menus are never cut off.
@MainActor
final class MenuBarOverlay: NSObject {
    private static let enabledKey = "nightbarEnabled"
    private static let cornerRadiusKey = "cornerRadius"

    /// The window level of the strips: just above the wallpaper.
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

    private let defaults: UserDefaults
    private var windows: [NSWindow] = []
    private var contrastViews: [ColorRemapView] = []

    /// Whether macOS currently draws the menu bar dark, with white text.
    var isMenuBarDark = true {
        didSet {
            contrastViews.forEach { $0.remap = .forMenuBar(isDark: isMenuBarDark) }
        }
    }

    var isEnabled: Bool {
        get { defaults.object(forKey: Self.enabledKey) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Self.enabledKey)
            updateWindows()
        }
    }

    var cornerRadius: CornerRadius {
        get { defaults.string(forKey: Self.cornerRadiusKey).flatMap(CornerRadius.init(rawValue:)) ?? .standard }
        set {
            defaults.set(newValue.rawValue, forKey: Self.cornerRadiusKey)
            updateWindows()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
    }

    func start() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
        updateWindows()
    }

    /// Rebuilds the strips, contrast layers and corners, so they match the current screens and settings.
    private func updateWindows() {
        // Hide the windows in the opposite order of showing them, so a contrast layer never sits
        // over a menu bar that has already lost its strip. That would flash for a frame.
        windows.reversed().forEach { $0.orderOut(nil) }
        windows = isEnabled ? NSScreen.screens.flatMap(makeWindows) : []
        contrastViews = windows.compactMap { $0.contentView as? ColorRemapView }
    }

    private func makeWindows(for screen: NSScreen) -> [NSWindow] {
        [makeStrip(for: screen)] + makeContrastLayer(for: screen) + makeCorners(for: screen)
    }

    private func makeStrip(for screen: NSScreen) -> NSWindow {
        let strip = makeOverlayWindow(frame: screen.menuBarFrame, level: Self.stripLevel)
        strip.backgroundColor = .black
        strip.isOpaque = true
        strip.orderFrontRegardless()
        return strip
    }

    /// Left out when the menu bar hides automatically: app windows then reach the top of the
    /// screen, and the remap would change their colours.
    private func makeContrastLayer(for screen: NSScreen) -> [NSWindow] {
        guard screen.reservesSpaceForMenuBar else { return [] }

        let window = makeOverlayWindow(frame: screen.menuBarFrame, level: Self.contrastLevel)
        window.backgroundColor = .clear
        window.isOpaque = false
        let remapView = ColorRemapView(remap: .forMenuBar(isDark: isMenuBarDark))
        remapView.addSubview(makeBottomEdgeCover(width: window.frame.width))
        window.contentView = remapView
        window.orderFrontRegardless()
        return [window]
    }

    /// A window right below the menu bar draws its dark border into the menu bar's last pixel
    /// row. The remap for a light menu bar would turn that border into a white line, so this
    /// black edge covers it.
    private func makeBottomEdgeCover(width: CGFloat) -> NSView {
        let cover = NSView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        cover.autoresizingMask = [.width]
        cover.wantsLayer = true
        cover.layer?.backgroundColor = NSColor.black.cgColor
        return cover
    }

    private func makeCorners(for screen: NSScreen) -> [NSWindow] {
        let radius = cornerRadius.points
        guard radius > 0 else { return [] }

        return ScreenCorner.allCases.map { corner in
            let frame = corner.frame(
                screenFrame: screen.frame, menuBarHeight: screen.menuBarFrame.height, radius: radius
            )
            let window = makeOverlayWindow(frame: frame, level: Self.cornerLevel)
            window.backgroundColor = .clear
            window.isOpaque = false
            window.contentView = CornerView(corner: corner, radius: radius)
            window.orderFrontRegardless()
            return window
        }
    }

    /// A borderless window that clicks pass through and that shows on every Space. It appears and
    /// disappears at once, without the fade macOS may give new windows.
    private func makeOverlayWindow(frame: CGRect, level: NSWindow.Level) -> NSWindow {
        let window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.animationBehavior = .none
        window.level = level
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        return window
    }

    @objc private func screensDidChange(_ notification: Notification) {
        updateWindows()
    }
}
