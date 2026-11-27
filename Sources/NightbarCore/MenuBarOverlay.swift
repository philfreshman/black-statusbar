import AppKit

/// Blacks out the menu bar of every screen, with one `ScreenOverlay` per screen.
@MainActor
final class MenuBarOverlay: NSObject {
    private static let enabledKey = "nightbarEnabled"
    private static let cornerRadiusKey = "cornerRadius"

    private let defaults: UserDefaults
    private var screenOverlays: [ScreenOverlay] = []

    /// Whether macOS currently draws the menu bar dark, with white text.
    var isMenuBarDark = true {
        didSet {
            screenOverlays.forEach { $0.setRemap(remap) }
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

    private var remap: ColorRemap {
        .forMenuBar(isDark: isMenuBarDark)
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

    /// Rebuilds the overlays, so they match the current screens and settings.
    private func updateWindows() {
        screenOverlays.forEach { $0.close() }
        screenOverlays = isEnabled
            ? NSScreen.screens.map { ScreenOverlay(screen: $0, cornerRadius: cornerRadius, remap: remap) }
            : []
    }

    @objc private func screensDidChange(_ notification: Notification) {
        updateWindows()
    }
}
