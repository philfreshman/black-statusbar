import Foundation

/// A version number such as `0.2.0`, as used in Nightbar's release tags (`v0.2.0`) and its Info.plist.
struct AppVersion: Sendable {
    let components: [Int]

    /// Reads `1.2.3` or `v1.2.3`. Returns nil when the text is not a dotted list of numbers.
    init?(_ text: String) {
        let trimmed = text.hasPrefix("v") ? String(text.dropFirst()) : text
        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        let numbers = parts.compactMap { Int($0) }
        guard !numbers.isEmpty, numbers.count == parts.count, numbers.allSatisfy({ $0 >= 0 }) else { return nil }
        components = numbers
    }

    /// The version of the running app, or nil when it runs outside an app bundle (for example via `swift run`).
    static var current: AppVersion? {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).flatMap(AppVersion.init)
    }

    private func padded(to other: AppVersion) -> [Int] {
        components + Array(repeating: 0, count: max(0, other.components.count - components.count))
    }
}

extension AppVersion: Comparable {
    /// Missing trailing parts count as zero, so `1.2` equals `1.2.0`.
    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.padded(to: rhs) == rhs.padded(to: lhs)
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.padded(to: rhs).lexicographicallyPrecedes(rhs.padded(to: lhs))
    }
}

extension AppVersion: CustomStringConvertible {
    var description: String {
        components.map(String.init).joined(separator: ".")
    }
}
