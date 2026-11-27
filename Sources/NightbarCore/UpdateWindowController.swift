import AppKit
import SwiftUI

/// The "Check for Updates" window. It checks for a newer release each time it is shown.
@MainActor
final class UpdateWindowController {
    private let model: UpdateModel
    private lazy var window = makeWindow()
    private var hasBeenShown = false

    private init(model: UpdateModel) {
        self.model = model
    }

    /// A window that checks GitHub for updates to the running app and installs them.
    static func make() -> UpdateWindowController {
        UpdateWindowController(
            model: UpdateModel(
                currentVersion: .current,
                checker: GitHubUpdateChecker(),
                installer: UpdateInstaller()
            ))
    }

    /// Brings the window to the front and checks for updates, unless an update is being or has been installed.
    func show() {
        if !hasBeenShown {
            window.center()
            hasBeenShown = true
        }
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
        Task { await model.check() }
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: UpdateView(model: model)))
        window.title = "Software Update"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        return window
    }
}
