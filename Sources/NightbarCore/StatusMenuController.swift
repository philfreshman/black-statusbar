import AppKit

/// The app's own icon in the menu bar, with its menu.
@MainActor
final class StatusMenuController: NSObject, NSMenuDelegate {
    private let overlay: MenuBarOverlay
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private lazy var toggleItem = makeItem("Nightbar", action: #selector(toggleBlackBar))
    private lazy var launchAtLoginItem = makeItem("Launch at Login", action: #selector(toggleLaunchAtLogin))

    init(overlay: MenuBarOverlay) {
        self.overlay = overlay
        super.init()
        statusItem.button?.image = NSImage(
            systemSymbolName: "menubar.rectangle", accessibilityDescription: "Nightbar"
        )
        statusItem.menu = makeMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        toggleItem.state = overlay.isEnabled ? .on : .off
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(launchAtLoginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    private func makeItem(_ title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func toggleBlackBar() {
        overlay.isEnabled.toggle()
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
