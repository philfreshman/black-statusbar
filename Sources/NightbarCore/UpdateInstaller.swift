import AppKit

/// Installs a release by downloading its zip, checking the app inside and swapping it in for the running app's bundle.
struct UpdateInstaller {
    /// Saves the file at the first URL to the second URL.
    typealias Download = @Sendable (URL, URL) async throws -> Void

    private let appURL: URL
    private let bundleIdentifier: String?
    private let download: Download

    /// `download` fetches the zip; tests pass a fake one instead of the network.
    init(
        appURL: URL = Bundle.main.bundleURL,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier,
        download: @escaping Download = UpdateInstaller.downloadFromNetwork
    ) {
        self.appURL = appURL
        self.bundleIdentifier = bundleIdentifier
        self.download = download
    }

    /// Returns the bundle identifier the download must have, or throws when this app cannot be replaced.
    private func checkCanReplaceApp() throws -> String {
        guard appURL.pathExtension == "app", let bundleIdentifier else { throw UpdateError.notRunningAsApp }
        let folder = appURL.deletingLastPathComponent()
        guard FileManager.default.isWritableFile(atPath: folder.path) else {
            throw UpdateError.folderNotWritable(folder)
        }
        return bundleIdentifier
    }

    /// A fresh temporary folder on the same volume as the app, so the final swap is a cheap, atomic rename.
    private func makeWorkFolder() throws -> URL {
        try FileManager.default.url(
            for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: appURL, create: true
        )
    }

    private func unpack(_ zip: URL, into folder: URL) async throws -> URL {
        do {
            try await Self.run("/usr/bin/ditto", ["-x", "-k", zip.path, folder.path])
        } catch {
            throw UpdateError.unpackFailed
        }
        return folder.appendingPathComponent("Nightbar.app")
    }

    /// Makes sure the unpacked app is Nightbar, at the version the release promised.
    private static func verify(_ app: URL, bundleIdentifier: String, version: AppVersion) throws {
        let infoPlist = app.appendingPathComponent("Contents/Info.plist")
        guard
            let data = try? Data(contentsOf: infoPlist),
            let info = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            info["CFBundleIdentifier"] as? String == bundleIdentifier,
            let versionText = info["CFBundleShortVersionString"] as? String,
            AppVersion(versionText) == version
        else { throw UpdateError.unexpectedDownload }
    }

    /// Runs a command without blocking the calling thread, and throws when it exits with a non-zero status.
    private static func run(_ executable: String, _ arguments: [String]) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        let status: Int32 = try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { continuation.resume(returning: $0.terminationStatus) }
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
        guard status == 0 else { throw CommandFailed() }
    }

    /// Callers only need to know that the command failed, not how.
    private struct CommandFailed: Error {}

    /// Downloads with URLSession and moves the file to `destination` straight away, before URLSession can delete it.
    private static let downloadFromNetwork: Download = { source, destination in
        let (file, response) = try await URLSession.shared.download(from: source)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            try? FileManager.default.removeItem(at: file)
            throw UpdateError.gitHubUnavailable(statusCode: http.statusCode)
        }
        try FileManager.default.moveItem(at: file, to: destination)
    }
}

extension UpdateInstaller: UpdateInstalling {
    func install(_ release: Release) async throws {
        let bundleIdentifier = try checkCanReplaceApp()
        let workFolder = try makeWorkFolder()
        defer { try? FileManager.default.removeItem(at: workFolder) }

        let zip = workFolder.appendingPathComponent(GitHubUpdateChecker.assetName)
        try await download(release.downloadURL, zip)
        let newApp = try await unpack(zip, into: workFolder)
        try Self.verify(newApp, bundleIdentifier: bundleIdentifier, version: release.version)
        try? await Self.run("/usr/bin/xattr", ["-dr", "com.apple.quarantine", newApp.path])
        _ = try FileManager.default.replaceItemAt(appURL, withItemAt: newApp)
    }

    @MainActor func relaunch() {
        // Waits for this process to exit, then opens the app. Values go in as arguments, never into the script.
        let script = #"while kill -0 "$1" 2>/dev/null; do sleep 0.2; done; /usr/bin/open "$2""#
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script, "sh", String(ProcessInfo.processInfo.processIdentifier), appURL.path]
        guard (try? process.run()) != nil else { return }
        NSApp.terminate(nil)
    }
}
