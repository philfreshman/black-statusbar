import AppKit

/// The app's own icon in the menu bar, with its menu.
@MainActor
final class StatusMenuController: NSObject, NSMenuDelegate {
    private let coordinator: WallpaperCoordinator
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private lazy var toggleItem = makeItem("Black Menu Bar", action: #selector(toggleBlackBar))
    private lazy var statusLine = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private lazy var refreshItem = makeItem("Refresh Now", action: #selector(refreshNow), key: "r")
    private lazy var nextPictureItem = makeItem("Next Picture", action: #selector(showNextPicture), key: "n")
    private lazy var intervalItems = RotationInterval.allCases.map { interval in
        let item = makeItem(interval.title, action: #selector(chooseInterval))
        item.tag = interval.rawValue
        return item
    }
    private lazy var launchAtLoginItem = makeItem("Launch at Login", action: #selector(toggleLaunchAtLogin))

    init(coordinator: WallpaperCoordinator) {
        self.coordinator = coordinator
        super.init()
        statusItem.button?.image = NSImage(
            systemSymbolName: "menubar.rectangle", accessibilityDescription: "Black Menu Bar"
        )
        statusItem.menu = makeMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        toggleItem.state = coordinator.isEnabled ? .on : .off
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        for item in intervalItems {
            item.state = item.tag == coordinator.rotationInterval.rawValue ? .on : .off
        }
        statusLine.title = statusDescription
    }

    private var statusDescription: String {
        if let error = coordinator.lastError { return error }
        return coordinator.isEnabled ? "Active" : "Off – original wallpaper shown"
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        statusLine.isEnabled = false

        menu.addItem(toggleItem)
        menu.addItem(statusLine)
        menu.addItem(.separator())
        menu.addItem(refreshItem)
        menu.addItem(nextPictureItem)
        menu.addItem(makeIntervalMenuItem())
        menu.addItem(.separator())
        menu.addItem(launchAtLoginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    /// Only used when the wallpaper is a folder of pictures.
    private func makeIntervalMenuItem() -> NSMenuItem {
        let submenu = NSMenu()
        intervalItems.forEach(submenu.addItem)
        let item = NSMenuItem(title: "Change Folder Picture", action: nil, keyEquivalent: "")
        item.submenu = submenu
        return item
    }

    private func makeItem(_ title: String, action: Selector, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func toggleBlackBar() {
        coordinator.isEnabled.toggle()
    }

    @objc private func refreshNow() {
        coordinator.retryUnreadableWallpapers()
    }

    @objc private func showNextPicture() {
        coordinator.showNextPicture()
    }

    @objc private func chooseInterval(_ sender: NSMenuItem) {
        guard let interval = RotationInterval(rawValue: sender.tag) else { return }
        coordinator.rotationInterval = interval
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            try LaunchAtLogin.setEnabled(!LaunchAtLogin.isEnabled)
        } catch {
            NSApp.activate()
            NSAlert(error: error).runModal()
        }
    }
}
