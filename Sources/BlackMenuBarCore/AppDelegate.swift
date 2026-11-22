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
}
