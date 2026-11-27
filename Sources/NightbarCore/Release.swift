import Foundation

/// A published Nightbar release on GitHub.
struct Release: Equatable, Sendable {
    let version: AppVersion
    /// The release's page on GitHub, with its notes.
    let pageURL: URL
    /// Where the release's `Nightbar.zip` can be downloaded.
    let downloadURL: URL
}

/// What a check for updates found.
enum UpdateCheckResult: Equatable, Sendable {
    case upToDate(latest: Release)
    case updateAvailable(Release)
}

/// Asks GitHub for the latest release and compares it with the running version.
protocol UpdateChecking: Sendable {
    /// A nil `current` version (the app runs outside a bundle) counts as out of date.
    func checkForUpdate(current: AppVersion?) async throws -> UpdateCheckResult
}

/// Downloads a release and puts it in place of the running app.
protocol UpdateInstalling: Sendable {
    /// Downloads the release and replaces the running app's bundle with it. The running app keeps running.
    func install(_ release: Release) async throws

    /// Quits Nightbar and opens the newly installed copy once this process has exited.
    @MainActor func relaunch()
}

/// Where Nightbar lives on the web, shown in the update window.
enum NightbarLinks {
    static let repository = URL(string: "https://github.com/philfreshman/nightbar")!
    static let releases = URL(string: "https://github.com/philfreshman/nightbar/releases")!
    static let latestReleaseAPI = URL(string: "https://api.github.com/repos/philfreshman/nightbar/releases/latest")!
}
