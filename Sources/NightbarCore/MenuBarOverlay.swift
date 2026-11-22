import AppKit

/// Puts a black strip behind the menu bar of every screen.
///
/// macOS picks the menu bar icon colour from what is behind the menu bar. With a black strip
/// there, the menu bar looks black and macOS draws white icons. The strip sits just above the
/// wallpaper, below desktop icons and windows, so it works with every wallpaper, including
/// live ones, and leaves the wallpaper itself untouched.
@MainActor
final class MenuBarOverlay: NSObject {
    private static let enabledKey = "nightbarEnabled"
    private static let stripLevel = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)

    private let defaults: UserDefaults
    private var strips: [NSWindow] = []

    var isEnabled: Bool {
        get { defaults.object(forKey: Self.enabledKey) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Self.enabledKey)
            updateStrips()
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
        updateStrips()
    }

    /// Rebuilds the strips, so they match the current screens and their menu bar heights.
    private func updateStrips() {
        strips.forEach { $0.orderOut(nil) }
        strips = isEnabled ? NSScreen.screens.map(makeStrip) : []
    }

    private func makeStrip(for screen: NSScreen) -> NSWindow {
        let strip = NSWindow(contentRect: screen.menuBarFrame, styleMask: .borderless, backing: .buffered, defer: false)
        strip.isReleasedWhenClosed = false
        strip.level = Self.stripLevel
        strip.backgroundColor = .black
        strip.isOpaque = true
        strip.hasShadow = false
        strip.ignoresMouseEvents = true
        strip.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        strip.orderFrontRegardless()
        return strip
    }

    @objc private func screensDidChange(_ notification: Notification) {
        updateStrips()
    }
}
