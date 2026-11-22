import Foundation
import UniformTypeIdentifiers

enum RotationInterval: Int, CaseIterable {
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case hour = 3600
    case day = 86400
    case never = 0

    var title: String {
        switch self {
        case .fiveMinutes: "Every 5 Minutes"
        case .fifteenMinutes: "Every 15 Minutes"
        case .hour: "Every Hour"
        case .day: "Every Day"
        case .never: "Never"
        }
    }
}

/// Rotates through the pictures of a wallpaper folder.
///
/// When the wallpaper is a folder, macOS rotates the pictures itself. Our black-bar copy
/// replaces the folder with a single image, so this app takes over the rotation.
final class FolderRotation {
    private enum Key {
        static let interval = "folderRotationInterval"
        static let currentImage = "folderRotationCurrentImage"
        static let lastChange = "folderRotationLastChange"
    }

    private let defaults: UserDefaults
    private let fileManager: FileManager
    private var skipRequested = false

    init(defaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.defaults = defaults
        self.fileManager = fileManager
    }

    var interval: RotationInterval {
        get { RotationInterval(rawValue: defaults.integer(forKey: Key.interval)) ?? .hour }
        set { defaults.set(newValue.rawValue, forKey: Key.interval) }
    }

    /// Makes the next call to `currentImage(in:)` move on to the next picture.
    func skipToNext() {
        skipRequested = true
    }

    /// The picture to show now. Moves to the next picture once the interval has passed.
    func currentImage(in folder: URL, excluding unusable: Set<String>, now: Date = .now) -> URL? {
        let images = imageFiles(in: folder).filter { !unusable.contains($0.path) }
        guard !images.isEmpty else { return nil }

        let current = storedCurrentImage.flatMap { stored in images.first { $0.path == stored.path } }
        guard let current, !shouldAdvance(now: now) else {
            return select(nextImage(after: current, in: images), now: now)
        }
        return current
    }

    private func shouldAdvance(now: Date) -> Bool {
        if skipRequested { return true }
        guard interval != .never, let lastChange else { return false }
        return now.timeIntervalSince(lastChange) >= TimeInterval(interval.rawValue)
    }

    private func nextImage(after current: URL?, in images: [URL]) -> URL {
        guard let current, let index = images.firstIndex(of: current) else { return images[0] }
        return images[(index + 1) % images.count]
    }

    private func select(_ image: URL, now: Date) -> URL {
        skipRequested = false
        defaults.set(image.path, forKey: Key.currentImage)
        defaults.set(now, forKey: Key.lastChange)
        return image
    }

    private func imageFiles(in folder: URL) -> [URL] {
        let contents = (try? fileManager.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: [.contentTypeKey], options: [.skipsHiddenFiles]
        )) ?? []
        return contents
            .filter { url in
                let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
                return type?.conforms(to: .image) ?? false
            }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    private var storedCurrentImage: URL? {
        defaults.string(forKey: Key.currentImage).map { URL(fileURLWithPath: $0) }
    }

    private var lastChange: Date? {
        defaults.object(forKey: Key.lastChange) as? Date
    }
}
