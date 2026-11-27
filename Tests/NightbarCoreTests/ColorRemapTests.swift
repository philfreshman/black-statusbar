import Testing

@testable import NightbarCore

struct ColorRemapTests {
    /// The grey macOS lays over the black strip on a light wallpaper, from top to bottom.
    private let greyOverStrip: [Float] = [0.45, 0.37, 0.29]

    /// The empty part of the battery icon on a dark menu bar, measured over the black strip.
    private let batteryEmptyPart: Float = 0.45

    /// The menu bar text on a dark menu bar, measured over the black strip.
    private let darkMenuBarText: Float = 0.9

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

    @Test func darkMenuBarKeepsTextNearlyWhite() {
        #expect(ColorRemap.darkMenuBar.apply(darkMenuBarText) >= 0.85)
    }

    @Test func darkMenuBarTurnsBlackAndFaintGreyBlack() {
        for grey: Float in [0, 0.1, 0.19] {
            #expect(ColorRemap.darkMenuBar.apply(grey) == 0)
        }
    }

    @Test func darkMenuBarKeepsGreyIconPartsGrey() {
        #expect((0.25...0.5).contains(ColorRemap.darkMenuBar.apply(batteryEmptyPart)))
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
