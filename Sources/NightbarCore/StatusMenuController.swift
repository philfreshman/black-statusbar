import AppKit

/// The app's own icon in the menu bar, with its menu.
///
/// The icon can be hidden from its menu. Opening Nightbar again while it runs shows it again.
/// The icon also tells the overlay whether macOS draws the menu bar light or dark.
@MainActor
final class StatusMenuController: NSObject {
    private static let iconHiddenKey = "iconHidden"
    private static let hideIconAlertSuppressedKey = "hideIconAlertSuppressed"

    private let overlay: MenuBarOverlay
    private let defaults: UserDefaults
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private lazy var toggleItem = makeItem("Nightbar", action: #selector(toggleBlackBar))
    private lazy var cornerRadiusItem = makeCornerRadiusItem()
    private lazy var launchAtLoginItem = makeItem("Launch at Login", action: #selector(toggleLaunchAtLogin))
    private lazy var hideIconItem = makeItem("Hide Icon", action: #selector(hideIcon))
    private lazy var checkForUpdatesItem = makeItem("Check for Updates…", action: #selector(checkForUpdates))
    private lazy var updateWindowController = UpdateWindowController.make()

    private var isIconHidden: Bool {
        get { defaults.bool(forKey: Self.iconHiddenKey) }
        set {
            defaults.set(newValue, forKey: Self.iconHiddenKey)
            statusItem.isVisible = !newValue
        }
    }

    init(overlay: MenuBarOverlay, defaults: UserDefaults = .standard) {
        self.overlay = overlay
        self.defaults = defaults
        super.init()
        statusItem.button?.image = MenuBarIcon.make()
        statusItem.menu = makeMenu()
        statusItem.isVisible = !isIconHidden
        watchMenuBarAppearance()
    }

    func showIcon() {
        isIconHidden = false
    }

    private func watchMenuBarAppearance() {
        let watcher = MenuBarAppearanceWatcher { [weak overlay] isDark in overlay?.isMenuBarDark = isDark }
        statusItem.button?.addSubview(watcher)
        overlay.isMenuBarDark = watcher.isDark
    }

    // MARK: - Building the menu

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(cornerRadiusItem)
        menu.addItem(.separator())
        menu.addItem(launchAtLoginItem)
        menu.addItem(hideIconItem)
        menu.addItem(.separator())
        menu.addItem(checkForUpdatesItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    private func makeItem(_ title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func makeCornerRadiusItem() -> NSMenuItem {
        let submenu = NSMenu()
        for radius in CornerRadius.allCases {
            let item = makeItem(radius.title, action: #selector(chooseCornerRadius))
            item.representedObject = radius
            submenu.addItem(item)
        }
        let item = NSMenuItem(title: "Rounded Corners", action: nil, keyEquivalent: "")
        item.submenu = submenu
        return item
    }

    // MARK: - Menu actions

    @objc private func toggleBlackBar() {
        overlay.isEnabled.toggle()
    }

    @objc private func chooseCornerRadius(_ sender: NSMenuItem) {
        guard let radius = sender.representedObject as? CornerRadius else { return }
        overlay.cornerRadius = radius
    }

    @objc private func hideIcon() {
        guard confirmHidingIcon() else { return }
        isIconHidden = true
    }

    /// Tells the user how to get the icon back, unless they asked not to be told again.
    private func confirmHidingIcon() -> Bool {
        guard !defaults.bool(forKey: Self.hideIconAlertSuppressedKey) else { return true }

        let alert = NSAlert()
        alert.messageText = "Hide the Nightbar icon?"
        alert.informativeText =
            "Nightbar keeps running. To show the icon again, open Nightbar from your Applications folder."
        alert.addButton(withTitle: "Hide Icon")
        alert.addButton(withTitle: "Cancel")
        alert.showsSuppressionButton = true

        NSApp.activate()
        let confirmed = alert.runModal() == .alertFirstButtonReturn
        if confirmed, alert.suppressionButton?.state == .on {
            defaults.set(true, forKey: Self.hideIconAlertSuppressedKey)
        }
        return confirmed
    }

    @objc private func checkForUpdates() {
        updateWindowController.show()
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

extension StatusMenuController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        toggleItem.state = overlay.isEnabled ? .on : .off
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        for item in cornerRadiusItem.submenu?.items ?? [] {
            item.state = item.representedObject as? CornerRadius == overlay.cornerRadius ? .on : .off
        }
    }
}
