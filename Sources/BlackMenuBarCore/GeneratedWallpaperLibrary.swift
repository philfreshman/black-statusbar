import CryptoKit
import Foundation

/// Keeps the black-bar wallpaper copies on disk and remembers which original
/// wallpaper each copy was made from, so the original can be restored later.
final class GeneratedWallpaperLibrary {
    private static let originalsKey = "originalWallpaperByGeneratedFile"

    let directory: URL
    private let defaults: UserDefaults
    private let fileManager: FileManager

    init(fileManager: FileManager = .default, defaults: UserDefaults = .standard) throws {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        directory = applicationSupport.appendingPathComponent("BlackMenuBar/Wallpapers", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        self.defaults = defaults
        self.fileManager = fileManager
    }

    func contains(_ url: URL) -> Bool {
        url.resolvingSymlinksInPath().deletingLastPathComponent().path == directory.resolvingSymlinksInPath().path
    }

    func exists(_ url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func original(for generated: URL) -> URL? {
        originals[generated.lastPathComponent].map { URL(fileURLWithPath: $0) }
    }

    func register(_ generated: URL, original: URL) {
        var updated = originals
        updated[generated.lastPathComponent] = original.path
        defaults.set(updated, forKey: Self.originalsKey)
    }

    /// The file name changes whenever the original, the screen size or the bar height
    /// changes. A new name forces macOS to reload the wallpaper instead of using its cache.
    func location(for original: URL, canvasSize: CGSize, barHeight: Int) -> URL {
        let modified = (try? original.resourceValues(forKeys: [.contentModificationDateKey]))?
            .contentModificationDate?.timeIntervalSince1970 ?? 0
        let digest = SHA256.hash(data: Data("\(original.path)|\(modified)".utf8))
        let identifier = digest.prefix(8).map { String(format: "%02x", $0) }.joined()
        let fileName = "\(identifier)-\(Int(canvasSize.width))x\(Int(canvasSize.height))-bar\(barHeight).png"
        return directory.appendingPathComponent(fileName)
    }

    private var originals: [String: String] {
        defaults.dictionary(forKey: Self.originalsKey) as? [String: String] ?? [:]
    }
}
