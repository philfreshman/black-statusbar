import Foundation

/// The window server's ID of a Space.
typealias SpaceID = UInt64

/// The Spaces of one display, as Mission Control lists them.
///
/// Read from the dictionaries the window server returns for its managed Spaces (see `Spaces`),
/// so the parsing can be tested without a window server.
struct DisplaySpaces: Equatable {
    /// What the window server calls a display when all displays share the same Spaces, because
    /// "Displays have separate Spaces" is off.
    static let sharedDisplayIdentifier = "Main"

    /// The kind of Space the window server reports for a desktop. Full-screen apps get Spaces
    /// of another kind, which Nightbar leaves alone.
    private static let desktopType = 0

    /// The display's UUID, or `sharedDisplayIdentifier`.
    let displayIdentifier: String
    /// The Space the display shows now.
    let currentSpaceID: SpaceID?
    /// The display's desktops in Mission Control order. Full-screen Spaces are left out.
    let desktopIDs: [SpaceID]

    init(displayIdentifier: String, currentSpaceID: SpaceID?, desktopIDs: [SpaceID]) {
        self.displayIdentifier = displayIdentifier
        self.currentSpaceID = currentSpaceID
        self.desktopIDs = desktopIDs
    }

    /// Reads one display's entry. Nil when it has no display identifier.
    init?(_ entry: [String: Any]) {
        guard let identifier = entry["Display Identifier"] as? String else { return nil }
        let spaces = entry["Spaces"] as? [[String: Any]] ?? []
        self.init(
            displayIdentifier: identifier,
            currentSpaceID: (entry["Current Space"] as? [String: Any]).flatMap(Self.spaceID),
            desktopIDs: spaces.filter { $0["type"] as? Int == Self.desktopType }.compactMap(Self.spaceID)
        )
    }

    /// Reads every display's entry, skipping the ones it cannot read.
    static func parse(_ entries: [[String: Any]]) -> [Self] {
        entries.compactMap(Self.init)
    }

    /// The Spaces of the display with this UUID: its own entry, or the shared one when all
    /// displays share the same Spaces.
    static func spaces(ofDisplay uuid: String?, in list: [Self]) -> Self? {
        list.first { $0.displayIdentifier == uuid }
            ?? list.first { $0.displayIdentifier == sharedDisplayIdentifier }
    }

    private static func spaceID(_ space: [String: Any]) -> SpaceID? {
        (space["ManagedSpaceID"] as? NSNumber)?.uint64Value
    }
}
