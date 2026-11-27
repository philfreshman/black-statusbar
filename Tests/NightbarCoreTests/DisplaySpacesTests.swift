import Testing

@testable import NightbarCore

struct DisplaySpacesTests {
    private static let builtIn = "37D8832A-2D66-02CA-B9F7-8F30A301B230"
    private static let external = "9C2A1F3B-0000-4000-8000-1234567890AB"

    private static func space(_ spaceID: Int, type: Int = 0) -> [String: Any] {
        ["ManagedSpaceID": spaceID, "id64": spaceID, "type": type]
    }

    private static func display(_ identifier: String, current: Int, spaces: [[String: Any]]) -> [String: Any] {
        ["Display Identifier": identifier, "Current Space": space(current), "Spaces": spaces]
    }

    @Test func readsDesktopsInMissionControlOrder() {
        let entries = [Self.display(Self.builtIn, current: 5, spaces: [Self.space(4), Self.space(5), Self.space(142)])]

        #expect(
            DisplaySpaces.parse(entries) == [
                DisplaySpaces(displayIdentifier: Self.builtIn, currentSpaceID: 5, desktopIDs: [4, 5, 142])
            ])
    }

    @Test func leavesOutFullScreenSpaces() {
        let entries = [Self.display(Self.builtIn, current: 4, spaces: [Self.space(4), Self.space(9, type: 4)])]

        #expect(DisplaySpaces.parse(entries).first?.desktopIDs == [4])
    }

    @Test func skipsEntriesWithoutDisplayIdentifier() {
        let entries: [[String: Any]] = [["Spaces": [Self.space(4)]]]

        #expect(DisplaySpaces.parse(entries).isEmpty)
    }

    @Test func findsSpacesOfEachDisplay() {
        let builtIn = DisplaySpaces(displayIdentifier: Self.builtIn, currentSpaceID: 4, desktopIDs: [4])
        let external = DisplaySpaces(displayIdentifier: Self.external, currentSpaceID: 7, desktopIDs: [7, 8])

        #expect(DisplaySpaces.spaces(ofDisplay: Self.external, in: [builtIn, external]) == external)
    }

    @Test func displaysShareSpacesWhenNotSeparate() {
        let shared = DisplaySpaces(
            displayIdentifier: DisplaySpaces.sharedDisplayIdentifier, currentSpaceID: 4, desktopIDs: [4, 5])

        #expect(DisplaySpaces.spaces(ofDisplay: Self.external, in: [shared]) == shared)
        #expect(DisplaySpaces.spaces(ofDisplay: nil, in: [shared]) == shared)
    }
}
