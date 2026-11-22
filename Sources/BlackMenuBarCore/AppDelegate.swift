import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: WallpaperCoordinator?
    private var statusMenu: StatusMenuController?

    override public init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            let coordinator = try WallpaperCoordinator()
            statusMenu = StatusMenuController(coordinator: coordinator)
            coordinator.start()
            self.coordinator = coordinator
        } catch {
            NSAlert(error: error).runModal()
            NSApp.terminate(nil)
        }
    }
}
