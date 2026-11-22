import AppKit
import BlackMenuBarCore

MainActor.assumeIsolated {
    let application = NSApplication.shared
    let appDelegate = AppDelegate()
    application.delegate = appDelegate
    application.setActivationPolicy(.accessory)
    application.run()
}
