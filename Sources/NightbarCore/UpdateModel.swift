import Foundation
import Observation

/// What the update window shows: a check for a newer release, then optionally its install.
///
/// A check finds the app up to date, finds an update, or fails. An update can then be installed,
/// which ends with the new copy in place (ready to restart into) or with an error.
@MainActor
@Observable
final class UpdateModel {
    /// The step the window is at, with the release it is about where there is one.
    enum State: Equatable {
        case checking
        case upToDate(latest: Release)
        case updateAvailable(Release)
        case installing(Release)
        case installed(Release)
        case failed(message: String)
    }

    private(set) var state: State = .checking

    /// The newest release the last successful check found, kept after a failure for its release notes.
    private(set) var latestRelease: Release?

    /// The running app's version, or nil when it runs outside an app bundle.
    let currentVersion: AppVersion?

    private let checker: UpdateChecking
    private let installer: UpdateInstalling

    init(currentVersion: AppVersion?, checker: UpdateChecking, installer: UpdateInstalling) {
        self.currentVersion = currentVersion
        self.checker = checker
        self.installer = installer
    }

    /// True while an update is being installed or once it is installed, when checking again would only confuse:
    /// the running copy is still the old version.
    private var isInstallStarted: Bool {
        switch state {
        case .installing, .installed: true
        default: false
        }
    }

    /// Asks for the latest release. Does nothing once an install has started.
    func check() async {
        guard !isInstallStarted else { return }
        state = .checking

        let outcome: State
        do {
            outcome = Self.state(for: try await checker.checkForUpdate(current: currentVersion))
        } catch {
            outcome = .failed(message: error.localizedDescription)
        }

        // An install may have started while this check was waiting, from the result of an earlier check.
        guard !isInstallStarted else { return }
        state = outcome
        latestRelease = Self.release(in: outcome) ?? latestRelease
    }

    /// Installs the update the last check found. Does nothing when no update is available.
    func installUpdate() async {
        guard case .updateAvailable(let release) = state else { return }
        state = .installing(release)
        do {
            try await installer.install(release)
            state = .installed(release)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    /// Quits Nightbar and opens the newly installed copy.
    func relaunch() {
        installer.relaunch()
    }

    private static func state(for result: UpdateCheckResult) -> State {
        switch result {
        case .upToDate(let latest): .upToDate(latest: latest)
        case .updateAvailable(let release): .updateAvailable(release)
        }
    }

    private static func release(in state: State) -> Release? {
        switch state {
        case .upToDate(let release), .updateAvailable(let release), .installing(let release), .installed(let release):
            release
        case .checking, .failed:
            nil
        }
    }
}
