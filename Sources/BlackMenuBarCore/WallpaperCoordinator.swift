import AppKit
import os

/// Swaps each screen's wallpaper for a copy with a black band behind the menu bar,
/// and swaps it back when the feature is turned off.
///
/// The "original" wallpaper is either a single picture or a folder of pictures.
/// For a folder, `FolderRotation` decides which picture is shown.
@MainActor
final class WallpaperCoordinator: NSObject {
    private static let enabledKey = "blackMenuBarEnabled"
    /// macOS sends no public notification when the wallpaper changes, so check regularly.
    private static let wallpaperCheckInterval: TimeInterval = 3

    private let workspace = NSWorkspace.shared
    private let library: GeneratedWallpaperLibrary
    private let composer = WallpaperComposer()
    private let rotation: FolderRotation
    private let defaults: UserDefaults
    private let log = Logger(subsystem: "BlackMenuBar", category: "wallpaper")

    private var wallpaperCheckTimer: Timer?
    private var isRefreshing = false
    private var needsAnotherRefresh = false
    /// Wallpapers that failed to load, so they are not retried every few seconds.
    private var unreadableWallpapers: Set<String> = []

    private(set) var lastError: String?

    var isEnabled: Bool {
        get { defaults.object(forKey: Self.enabledKey) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Self.enabledKey)
            refresh()
        }
    }

    init(defaults: UserDefaults = .standard) throws {
        self.defaults = defaults
        library = try GeneratedWallpaperLibrary(defaults: defaults)
        rotation = FolderRotation(defaults: defaults)
        super.init()
    }

    func start() {
        observeSystemChanges()
        startWallpaperChecks()
        refresh()
    }

    func refresh() {
        guard !isRefreshing else {
            needsAnotherRefresh = true
            return
        }
        isRefreshing = true
        Task {
            await updateAllScreens()
            isRefreshing = false
            if needsAnotherRefresh {
                needsAnotherRefresh = false
                refresh()
            }
        }
    }

    var rotationInterval: RotationInterval {
        get { rotation.interval }
        set { rotation.interval = newValue }
    }

    func retryUnreadableWallpapers() {
        unreadableWallpapers.removeAll()
        refresh()
    }

    func showNextPicture() {
        rotation.skipToNext()
        refresh()
    }

    // MARK: - Updating screens

    private func updateAllScreens() async {
        var errors: [String] = []
        for screen in NSScreen.screens {
            do {
                if isEnabled {
                    try await applyBlackBar(to: screen)
                } else {
                    try restoreOriginal(on: screen)
                }
            } catch {
                log.error("Updating \(screen.localizedName, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
                errors.append(error.localizedDescription)
            }
        }
        lastError = errors.first
    }

    private func applyBlackBar(to screen: NSScreen) async throws {
        guard
            let current = workspace.desktopImageURL(for: screen),
            let original = originalWallpaper(behind: current),
            let picture = pictureToShow(for: original)
        else { return }

        let canvasSize = screen.pixelSize
        let barHeight = screen.menuBarPixelHeight
        let target = library.location(for: picture, canvasSize: canvasSize, barHeight: barHeight)
        guard target.path != current.standardizedFileURL.path else { return }

        if !library.exists(target) {
            try await render(picture, to: target, canvasSize: canvasSize, barHeight: barHeight)
        }
        library.register(target, original: original)
        try setWallpaper(target, on: screen)
    }

    private func restoreOriginal(on screen: NSScreen) throws {
        guard
            let current = workspace.desktopImageURL(for: screen),
            library.contains(current),
            let original = library.original(for: current)
        else { return }

        try setWallpaper(original, on: screen)
    }

    /// Returns the user's real wallpaper (a picture or a folder), even when one of our copies is shown.
    private func originalWallpaper(behind current: URL) -> URL? {
        let original = library.contains(current) ? library.original(for: current) : current
        guard let original, library.exists(original) else { return nil }
        return original
    }

    private func pictureToShow(for original: URL) -> URL? {
        guard isFolder(original) else {
            return unreadableWallpapers.contains(original.path) ? nil : original
        }
        return rotation.currentImage(in: original, excluding: unreadableWallpapers)
    }

    private func isFolder(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }

    /// Image work runs off the main thread so the menu stays responsive.
    private func render(_ original: URL, to target: URL, canvasSize: CGSize, barHeight: Int) async throws {
        let composer = composer
        do {
            try await Task.detached(priority: .utility) {
                try composer.render(wallpaper: original, to: target, canvasSize: canvasSize, barHeight: barHeight)
            }.value
        } catch WallpaperComposerError.unreadableImage(let url) {
            unreadableWallpapers.insert(url.path)
            throw WallpaperComposerError.unreadableImage(url)
        }
    }

    private func setWallpaper(_ url: URL, on screen: NSScreen) throws {
        try workspace.setDesktopImageURL(url, for: screen, options: [
            .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
            .allowClipping: true,
            .fillColor: NSColor.black,
        ])
    }

    // MARK: - Watching for changes

    private func observeSystemChanges() {
        let workspaceCenter = workspace.notificationCenter
        workspaceCenter.addObserver(
            self, selector: #selector(systemDidChange), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil
        )
        workspaceCenter.addObserver(
            self, selector: #selector(systemDidChange), name: NSWorkspace.didWakeNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(systemDidChange),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
    }

    private func startWallpaperChecks() {
        let timer = Timer(timeInterval: Self.wallpaperCheckInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        timer.tolerance = 1
        RunLoop.main.add(timer, forMode: .common)
        wallpaperCheckTimer = timer
    }

    @objc private func systemDidChange(_ notification: Notification) {
        refresh()
    }
}
