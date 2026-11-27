import AppKit

/// Blacks out the menu bar of every screen, on every Space the user visits.
///
/// Each screen gets one `ScreenOverlay` per Space. AppKit can only put a window on the Space
/// that is active, so a Space gets its overlay the first time it becomes active. Full-screen
/// apps are left alone.
@MainActor
final class MenuBarOverlay: NSObject {
    private static let enabledKey = "nightbarEnabled"
    private static let cornerRadiusKey = "cornerRadius"

    private let defaults: UserDefaults
    private var screenOverlays: [ScreenOverlay] = []
    private var screenLayouts: [ScreenLayout] = []

    /// Whether macOS currently draws the menu bar dark, with white text.
    var isMenuBarDark = true {
        didSet {
            for overlay in screenOverlays {
                overlay.setRemap(remap)
            }
        }
    }

    /// Whether Nightbar blacks out the menu bar. Saved in user defaults; changing it rebuilds the overlays.
    var isEnabled: Bool {
        get { defaults.object(forKey: Self.enabledKey) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Self.enabledKey)
            rebuild()
        }
    }

    /// How round the screen corners are. Saved in user defaults; changing it rebuilds the overlays.
    var cornerRadius: CornerRadius {
        get { defaults.string(forKey: Self.cornerRadiusKey).flatMap(CornerRadius.init(rawValue:)) ?? .standard }
        set {
            defaults.set(newValue.rawValue, forKey: Self.cornerRadiusKey)
            rebuild()
        }
    }

    private var remap: ColorRemap {
        .forMenuBar(isDark: isMenuBarDark)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
    }

    /// Covers the screens' active Spaces and starts following changes to screens and Spaces.
    func start() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(activeSpaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification, object: nil
        )
        screenLayouts = ScreenLayout.current
        rebuild()
    }

    // MARK: - Overlays

    /// Drops the overlays of every Space and covers the active ones again, so they match the
    /// current screens and settings. Other Spaces get theirs when the user next visits them.
    private func rebuild() {
        for overlay in screenOverlays {
            overlay.close()
        }
        screenOverlays = []
        coverActiveSpaces()
    }

    /// Gives the active Space of every screen exactly one overlay.
    private func coverActiveSpaces() {
        guard isEnabled else { return }
        NSScreen.screens.forEach(coverActiveSpace)
    }

    private func coverActiveSpace(of screen: NSScreen) {
        let overlays = screenOverlays.filter { $0.displayID == screen.displayID && $0.isOnActiveSpace }
        guard overlays.isEmpty else {
            removeOverlays(overlays.dropFirst())
            return
        }
        guard !FullScreenDetection.showsFullScreenWindow(on: screen.displayID) else { return }

        screenOverlays.append(ScreenOverlay(screen: screen, cornerRadius: cornerRadius, remap: remap))
    }

    /// When the user removes a Space, macOS moves its windows to another one, which then has
    /// two overlays. Two contrast layers would remap the menu bar twice.
    private func removeOverlays(_ duplicates: ArraySlice<ScreenOverlay>) {
        for duplicate in duplicates {
            duplicate.close()
        }
        screenOverlays.removeAll { overlay in duplicates.contains { $0 === overlay } }
    }

    // MARK: - Notifications

    @objc private func activeSpaceDidChange(_: Notification) {
        coverActiveSpaces()
    }

    /// macOS posts this for many reasons. Rebuilding drops the overlays of the other Spaces, so
    /// it only happens when a screen or its menu bar really changed.
    @objc private func screensDidChange(_: Notification) {
        let layouts = ScreenLayout.current
        guard layouts != screenLayouts else { return }
        screenLayouts = layouts
        rebuild()
    }
}

/// The parts of a screen that decide where its overlay windows go.
private struct ScreenLayout: Equatable {
    let displayID: CGDirectDisplayID?
    let frame: CGRect
    let menuBarFrame: CGRect
    let reservesSpaceForMenuBar: Bool

    @MainActor
    static var current: [ScreenLayout] {
        NSScreen.screens.map {
            ScreenLayout(
                displayID: $0.displayID, frame: $0.frame,
                menuBarFrame: $0.menuBarFrame, reservesSpaceForMenuBar: $0.reservesSpaceForMenuBar
            )
        }
    }
}
