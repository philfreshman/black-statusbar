import AppKit

@MainActor
public final class AppDelegate: NSObject {
    private let overlay = MenuBarOverlay()
    private var statusMenu: StatusMenuController?

    override public init() {
        super.init()
    }
}

extension AppDelegate: NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        statusMenu = StatusMenuController(overlay: overlay)
        overlay.start()
    }

    /// Opening Nightbar while it already runs shows its icon again, in case it was hidden.
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusMenu?.showIcon()
        return false
    }
}
