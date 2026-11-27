import Foundation

/// Why checking for or installing an update failed, worded for the update window.
enum UpdateError: Error, Equatable {
    /// GitHub answered with an HTTP status outside 200–299.
    case gitHubUnavailable(statusCode: Int)
    /// GitHub's answer was not the release data Nightbar expects.
    case unreadableResponse
    /// The release's tag is not a version number such as `v0.2.0`.
    case invalidVersionTag(String)
    /// The release has no `Nightbar.zip` to download.
    case missingDownload
    /// Nightbar runs outside an app bundle, for example via `swift run`.
    case notRunningAsApp
    /// Nightbar may not write to the folder its app lives in.
    case folderNotWritable(URL)
    /// The download could not be unpacked.
    case unpackFailed
    /// The unpacked download is not the expected Nightbar release.
    case unexpectedDownload

    private static let installScript = "curl -fsSL https://nightbar.app/install.sh | bash"
}

extension UpdateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .gitHubUnavailable(let statusCode) where statusCode == 403 || statusCode == 429:
            "GitHub could not be reached because it limits how often Nightbar may ask. Try again in an hour."
        case .gitHubUnavailable(let statusCode):
            "GitHub could not be reached (HTTP \(statusCode)). Try again later."
        case .unreadableResponse:
            "GitHub's answer could not be read. Try again later."
        case .invalidVersionTag(let tag):
            "The latest release's tag “\(tag)” is not a version number."
        case .missingDownload:
            "The latest release has no Nightbar.zip to download."
        case .notRunningAsApp:
            "Nightbar is not running as an app, so it cannot update itself."
        case .folderNotWritable(let folder):
            "Nightbar may not write to \(folder.path). Reinstall it with “\(Self.installScript)” or download it from nightbar.app."
        case .unpackFailed:
            "The download could not be unpacked."
        case .unexpectedDownload:
            "The download does not contain the expected Nightbar version."
        }
    }
}
