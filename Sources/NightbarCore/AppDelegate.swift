import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let overlay = MenuBarOverlay()
    private var statusMenu: StatusMenuController?

    override public init() {
        super.init()
    }

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
