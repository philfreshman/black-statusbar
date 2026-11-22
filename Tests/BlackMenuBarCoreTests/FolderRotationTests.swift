import Foundation
import Testing
@testable import BlackMenuBarCore

struct FolderRotationTests {
    private let folder: URL
    private let defaults: UserDefaults
    private let rotation: FolderRotation
    private let start = Date(timeIntervalSince1970: 1_000_000)

    init() throws {
        folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        for name in ["b.png", "a.jpg", "c.heic", "notes.txt"] {
            FileManager.default.createFile(atPath: folder.appendingPathComponent(name).path, contents: Data())
        }
        let suiteName = "FolderRotationTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
        rotation = FolderRotation(defaults: defaults)
        rotation.interval = .hour
    }

    @Test func startsWithFirstPictureByName() {
        #expect(rotation.currentImage(in: folder, excluding: [], now: start)?.lastPathComponent == "a.jpg")
    }

    @Test func keepsPictureUntilIntervalPasses() {
        _ = rotation.currentImage(in: folder, excluding: [], now: start)

        let later = start.addingTimeInterval(3599)

        #expect(rotation.currentImage(in: folder, excluding: [], now: later)?.lastPathComponent == "a.jpg")
    }

    @Test func movesToNextPictureAfterInterval() {
        _ = rotation.currentImage(in: folder, excluding: [], now: start)

        let later = start.addingTimeInterval(3600)

        #expect(rotation.currentImage(in: folder, excluding: [], now: later)?.lastPathComponent == "b.png")
    }

    @Test func skipToNextMovesImmediately() {
        _ = rotation.currentImage(in: folder, excluding: [], now: start)

        rotation.skipToNext()

        #expect(rotation.currentImage(in: folder, excluding: [], now: start)?.lastPathComponent == "b.png")
    }

    @Test func wrapsAroundAndIgnoresNonImages() {
        _ = rotation.currentImage(in: folder, excluding: [], now: start)
        let names = (1...3).map { step in
            rotation.currentImage(in: folder, excluding: [], now: start.addingTimeInterval(Double(step) * 3600))?
                .lastPathComponent
        }

        #expect(names == ["b.png", "c.heic", "a.jpg"])
    }

    @Test func skipsExcludedPictures() throws {
        let first = try #require(rotation.currentImage(in: folder, excluding: [], now: start))
        let freshRotation = FolderRotation(defaults: try #require(UserDefaults(suiteName: UUID().uuidString)))

        let picture = freshRotation.currentImage(in: folder, excluding: [first.path], now: start)

        #expect(picture?.lastPathComponent == "b.png")
    }
}
