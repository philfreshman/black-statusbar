import CoreGraphics
import Testing

@testable import NightbarCore

struct FullScreenDetectionTests {
    private let display = CGRect(x: 0, y: 0, width: 1728, height: 1117)

    @Test func windowCoveringWholeDisplayIsFullScreen() {
        #expect(FullScreenDetection.showsFullScreenWindow(displayBounds: display, appWindowBounds: [display]))
    }

    @Test func maximisedWindowBelowMenuBarIsNotFullScreen() {
        let maximised = CGRect(x: 0, y: 33, width: 1728, height: 1084)

        #expect(!FullScreenDetection.showsFullScreenWindow(displayBounds: display, appWindowBounds: [maximised]))
    }

    @Test func windowOnAnotherDisplayIsNotFullScreen() {
        let otherDisplay = CGRect(x: 1728, y: 0, width: 2560, height: 1440)

        #expect(!FullScreenDetection.showsFullScreenWindow(displayBounds: display, appWindowBounds: [otherDisplay]))
    }
}
