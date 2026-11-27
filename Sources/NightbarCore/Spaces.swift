import AppKit

extension Notification.Name {
    /// Posted on the main queue when the user adds or removes a Space, for example in Mission Control.
    static let spacesDidChange = Notification.Name("NightbarSpacesDidChange")
}

/// Lists the Spaces of each display and puts windows on Spaces that are not active.
///
/// AppKit only puts windows on the active Space. This uses SkyLight, the private framework behind
/// the window server, which Mission Control uses itself. If a future macOS removes the functions,
/// `displaySpaces` returns nil, and Nightbar covers each Space when the user first visits it.
@MainActor
enum Spaces {
    private static let skyLight = SkyLight.load()

    /// The Spaces of every display, or nil when SkyLight is not available.
    static var displaySpaces: [DisplaySpaces]? {
        guard let skyLight, let list = skyLight.copyManagedDisplaySpaces(skyLight.connection) else { return nil }
        return DisplaySpaces.parse(list.takeRetainedValue() as? [[String: Any]] ?? [])
    }

    /// The Spaces of a screen, picked from a list `displaySpaces` returned.
    static func spaces(of screen: NSScreen, in list: [DisplaySpaces]) -> DisplaySpaces? {
        DisplaySpaces.spaces(ofDisplay: screen.displayID.flatMap(uuidString), in: list)
    }

    /// The Spaces a window is on. Empty when SkyLight is not available or the window is not shown.
    static func spaceIDs(of window: NSWindow) -> [SpaceID] {
        guard
            let skyLight,
            let spaces = skyLight.copySpacesForWindows(
                skyLight.connection, SkyLight.allSpacesMask, [window.windowNumber] as CFArray)
        else { return [] }
        return (spaces.takeRetainedValue() as? [NSNumber] ?? []).map(\.uint64Value)
    }

    /// Puts windows on a Space. A window that is not shown yet then appears there, not on the active Space.
    static func move(_ windows: [NSWindow], to space: SpaceID) {
        guard let skyLight else { return }
        let windowNumbers = windows.map(\.windowNumber) as CFArray
        skyLight.addWindowsToSpaces(skyLight.connection, windowNumbers, [space] as CFArray)
    }

    /// Starts posting `spacesDidChange` when the user adds or removes a Space. macOS has no public
    /// notification for that.
    static func startObservingChanges() {
        guard let skyLight else { return }
        for event in [SkyLight.spaceCreatedEvent, SkyLight.spaceDestroyedEvent] {
            _ = skyLight.registerNotifyProc(skyLight.connection, postSpacesDidChange, event, nil)
        }
    }

    /// The window server names displays by UUID in its list of Spaces.
    private static func uuidString(of displayID: CGDirectDisplayID) -> String? {
        guard let uuid = CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil, uuid) as String?
    }
}

/// Called by the window server for the events `Spaces` registers. Posts on the main queue, after
/// the window server has updated its list of Spaces.
private let postSpacesDidChange: SkyLight.NotifyProc = { _, _, _, _, _ in
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: .spacesDidChange, object: nil)
    }
}

/// The SkyLight functions `Spaces` uses, looked up by name at run time.
private struct SkyLight {
    typealias ConnectionID = Int32
    typealias NotifyProc =
        @convention(c) (
            UInt32, UnsafeMutableRawPointer?, Int, UnsafeMutableRawPointer?, Int32
        ) -> Void
    typealias MainConnectionID = @convention(c) () -> ConnectionID
    typealias CopyManagedDisplaySpaces = @convention(c) (ConnectionID) -> Unmanaged<CFArray>?
    typealias CopySpacesForWindows = @convention(c) (ConnectionID, Int32, CFArray) -> Unmanaged<CFArray>?
    typealias AddWindowsToSpaces = @convention(c) (ConnectionID, CFArray, CFArray) -> Void
    typealias RegisterNotifyProc = @convention(c) (ConnectionID, NotifyProc, UInt32, UnsafeMutableRawPointer?) -> Int32

    /// Asks for the Spaces a window is on, whether they are shown or not.
    static let allSpacesMask: Int32 = 0x7
    static let spaceCreatedEvent: UInt32 = 1327
    static let spaceDestroyedEvent: UInt32 = 1328

    private static let path = "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight"

    /// Nightbar's connection to the window server.
    let connection: ConnectionID
    let copyManagedDisplaySpaces: CopyManagedDisplaySpaces
    let copySpacesForWindows: CopySpacesForWindows
    let addWindowsToSpaces: AddWindowsToSpaces
    let registerNotifyProc: RegisterNotifyProc

    /// Nil when the framework or one of the functions is missing.
    static func load() -> Self? {
        guard
            let handle = dlopen(path, RTLD_LAZY),
            let mainConnectionID: MainConnectionID = function("SLSMainConnectionID", in: handle),
            let copyManagedDisplaySpaces: CopyManagedDisplaySpaces = function(
                "SLSCopyManagedDisplaySpaces", in: handle),
            let copySpacesForWindows: CopySpacesForWindows = function("SLSCopySpacesForWindows", in: handle),
            let addWindowsToSpaces: AddWindowsToSpaces = function("SLSAddWindowsToSpaces", in: handle),
            let registerNotifyProc: RegisterNotifyProc = function("SLSRegisterConnectionNotifyProc", in: handle)
        else { return nil }

        return Self(
            connection: mainConnectionID(),
            copyManagedDisplaySpaces: copyManagedDisplaySpaces,
            copySpacesForWindows: copySpacesForWindows,
            addWindowsToSpaces: addWindowsToSpaces,
            registerNotifyProc: registerNotifyProc
        )
    }

    private static func function<Function>(_ name: String, in handle: UnsafeMutableRawPointer) -> Function? {
        dlsym(handle, name).map { unsafeBitCast($0, to: Function.self) }
    }
}
