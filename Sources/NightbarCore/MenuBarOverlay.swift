import AppKit

/// Puts a black strip behind the menu bar of every screen, and black rounded corners below it.
///
/// macOS picks the menu bar icon colour from what is behind the menu bar. With a black strip
/// there, the menu bar looks black and macOS draws white icons. The strip sits just above the
/// wallpaper, below desktop icons and windows, so it works with every wallpaper, including
/// live ones, and leaves the wallpaper itself untouched.
///
/// The corners sit above windows, so the screen area below the menu bar looks like a rounded
/// rectangle even when a window fills it. They stay below menus, so menus are never cut off.
@MainActor
final class MenuBarOverlay: NSObject {
    private static let enabledKey = "nightbarEnabled"
    private static let cornerRadiusKey = "cornerRadius"
    private static let stripLevel = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
    private static let cornerLevel = NSWindow.Level.statusBar

    private let defaults: UserDefaults
    private var windows: [NSWindow] = []

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

    /// Rebuilds the strips and corners, so they match the current screens and settings.
    private func updateWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows = isEnabled ? NSScreen.screens.flatMap(makeWindows) : []
    }

    private func makeWindows(for screen: NSScreen) -> [NSWindow] {
        [makeStrip(for: screen)] + makeCorners(for: screen)
    }

    private func makeStrip(for screen: NSScreen) -> NSWindow {
        let strip = makeOverlayWindow(frame: screen.menuBarFrame, level: Self.stripLevel)
        strip.backgroundColor = .black
        strip.isOpaque = true
        strip.orderFrontRegardless()
        return strip
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

    /// A borderless window that clicks pass through and that shows on every Space.
    private func makeOverlayWindow(frame: CGRect, level: NSWindow.Level) -> NSWindow {
        let window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
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
