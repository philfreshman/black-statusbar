import AppKit

/// The app's own icon in the menu bar, with its menu.
@MainActor
final class StatusMenuController: NSObject, NSMenuDelegate {
    private let overlay: MenuBarOverlay
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private lazy var toggleItem = makeItem("Nightbar", action: #selector(toggleBlackBar))
    private lazy var cornerRadiusItem = makeCornerRadiusItem()
    private lazy var launchAtLoginItem = makeItem("Launch at Login", action: #selector(toggleLaunchAtLogin))

    init(overlay: MenuBarOverlay) {
        self.overlay = overlay
        super.init()
        statusItem.button?.image = MenuBarIcon.make()
        statusItem.menu = makeMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        toggleItem.state = overlay.isEnabled ? .on : .off
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        for item in cornerRadiusItem.submenu?.items ?? [] {
            item.state = item.representedObject as? CornerRadius == overlay.cornerRadius ? .on : .off
        }
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(cornerRadiusItem)
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

    @objc private func toggleBlackBar() {
        overlay.isEnabled.toggle()
    }

    @objc private func chooseCornerRadius(_ sender: NSMenuItem) {
        guard let radius = sender.representedObject as? CornerRadius else { return }
        overlay.cornerRadius = radius
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
