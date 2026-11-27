import Testing

@testable import NightbarCore

struct ColorRemapTests {
    /// The grey macOS lays over the black strip on a light wallpaper, from top to bottom.
    private let greyOverStrip: [Float] = [0.45, 0.37, 0.29]

    @Test func lightMenuBarTurnsBlackTextWhite() {
        #expect(ColorRemap.lightMenuBar.apply(0) == 1)
    }

    @Test func lightMenuBarTurnsGreyBlack() {
        for grey in greyOverStrip {
            #expect(ColorRemap.lightMenuBar.apply(grey) == 0)
        }
    }

    @Test func darkMenuBarKeepsWhiteTextWhite() {
        #expect(ColorRemap.darkMenuBar.apply(1) == 1)
    }

    @Test func darkMenuBarTurnsGreyAndBlackBlack() {
        for grey in greyOverStrip + [0] {
            #expect(ColorRemap.darkMenuBar.apply(grey) == 0)
        }
    }

    @Test func picksRemapForMenuBarAppearance() {
        #expect(ColorRemap.forMenuBar(isDark: true) == .darkMenuBar)
        #expect(ColorRemap.forMenuBar(isDark: false) == .lightMenuBar)
    }

    @Test func matrixAppliesRemapToColourChannelsAndKeepsAlpha() {
        let remap = ColorRemap(gain: -2, offset: 1)

        #expect(
            remap.matrix == [
                -2, 0, 0, 0, 1,
                0, -2, 0, 0, 1,
                0, 0, -2, 0, 1,
                0, 0, 0, 1, 0,
            ])
    }
}
