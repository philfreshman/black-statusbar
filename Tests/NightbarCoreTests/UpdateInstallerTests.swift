import Foundation
import Testing

@testable import NightbarCore

struct UpdateInstallerTests {
    private static let bundleIdentifier = "app.nightbar.tests"
    private static let installedVersion = "0.1.0"
    private static let release = Release(
        version: AppVersion("0.2.0")!,
        pageURL: URL(string: "https://example.com/release")!,
        downloadURL: URL(string: "https://example.com/Nightbar.zip")!
    )

    @Test func refusesWhenNotRunningAsAnApp() async throws {
        let folder = try TemporaryFolder()
        let installer = UpdateInstaller(
            appURL: folder.url.appendingPathComponent("debug/Nightbar"),
            bundleIdentifier: nil,
            download: { _, _ in Issue.record("Should not download") }
        )

        await #expect(throws: UpdateError.notRunningAsApp) {
            try await installer.install(Self.release)
        }
    }

    @Test func refusesWhenTheAppFolderIsNotWritable() async throws {
        let folder = try TemporaryFolder()
        let applications = folder.url.appendingPathComponent("Applications")
        let app = try FakeApp.make(
            in: applications, bundleIdentifier: Self.bundleIdentifier, version: Self.installedVersion
        )
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: applications.path)
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: applications.path) }
        let installer = UpdateInstaller(
            appURL: app,
            bundleIdentifier: Self.bundleIdentifier,
            download: { _, _ in Issue.record("Should not download") }
        )

        let error = await #expect(throws: UpdateError.self) {
            try await installer.install(Self.release)
        }
        guard case .folderNotWritable(let folder) = error else {
            Issue.record("Expected folderNotWritable, got \(String(describing: error))")
            return
        }
        #expect(folder.standardizedFileURL.path == applications.standardizedFileURL.path)
    }

    @Test func replacesTheAppWithTheDownloadedRelease() async throws {
        let folder = try TemporaryFolder()
        let app = try makeInstalledApp(in: folder)
        let zip = try FakeApp.zip(in: folder.url, bundleIdentifier: Self.bundleIdentifier, version: "0.2.0")
        let installer = UpdateInstaller(appURL: app, bundleIdentifier: Self.bundleIdentifier, download: copying(zip))

        try await installer.install(Self.release)

        #expect(try FakeApp.version(of: app) == "0.2.0")
    }

    @Test(arguments: [("app.someone.else", "0.2.0"), (bundleIdentifier, "0.1.5")])
    func keepsTheAppWhenTheDownloadIsNotTheRelease(identifier: String, version: String) async throws {
        let folder = try TemporaryFolder()
        let app = try makeInstalledApp(in: folder)
        let zip = try FakeApp.zip(in: folder.url, bundleIdentifier: identifier, version: version)
        let installer = UpdateInstaller(appURL: app, bundleIdentifier: Self.bundleIdentifier, download: copying(zip))

        await #expect(throws: UpdateError.unexpectedDownload) {
            try await installer.install(Self.release)
        }
        #expect(try FakeApp.version(of: app) == Self.installedVersion)
    }

    @Test func failsWhenTheDownloadIsNotAZip() async throws {
        let folder = try TemporaryFolder()
        let app = try makeInstalledApp(in: folder)
        let installer = UpdateInstaller(appURL: app, bundleIdentifier: Self.bundleIdentifier) { _, destination in
            try Data("not a zip".utf8).write(to: destination)
        }

        await #expect(throws: UpdateError.unpackFailed) {
            try await installer.install(Self.release)
        }
        #expect(try FakeApp.version(of: app) == Self.installedVersion)
    }

    /// The running app, at `installedVersion`, in an Applications folder of its own.
    private func makeInstalledApp(in folder: TemporaryFolder) throws -> URL {
        try FakeApp.make(
            in: folder.url.appendingPathComponent("Applications"), bundleIdentifier: Self.bundleIdentifier,
            version: Self.installedVersion
        )
    }

    /// A fake download that copies a local zip instead of fetching one.
    private func copying(_ zip: URL) -> UpdateInstaller.Download {
        { _, destination in try FileManager.default.copyItem(at: zip, to: destination) }
    }
}

/// A minimal `Nightbar.app`: just enough Info.plist for the installer's checks.
private enum FakeApp {
    static func make(in folder: URL, bundleIdentifier: String, version: String) throws -> URL {
        let app = folder.appendingPathComponent("Nightbar.app")
        let contents = app.appendingPathComponent("Contents")
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let info = ["CFBundleIdentifier": bundleIdentifier, "CFBundleShortVersionString": version]
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: contents.appendingPathComponent("Info.plist"))
        return app
    }

    /// Zips a fake app the way the release workflow does, with `Nightbar.app` at the top of the zip.
    static func zip(in folder: URL, bundleIdentifier: String, version: String) throws -> URL {
        let app = try make(
            in: folder.appendingPathComponent("release"), bundleIdentifier: bundleIdentifier, version: version)
        let zip = folder.appendingPathComponent("Nightbar.zip")
        let ditto = try Process.run(
            URL(fileURLWithPath: "/usr/bin/ditto"), arguments: ["-c", "-k", "--keepParent", app.path, zip.path])
        ditto.waitUntilExit()
        try #require(ditto.terminationStatus == 0)
        return zip
    }

    static func version(of app: URL) throws -> String? {
        let data = try Data(contentsOf: app.appendingPathComponent("Contents/Info.plist"))
        let info = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        return info?["CFBundleShortVersionString"] as? String
    }
}

/// A folder of its own under the system's temporary folder, removed when the test is done with it.
private final class TemporaryFolder {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("NightbarTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}
