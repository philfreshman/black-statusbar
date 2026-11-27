/// Changes every colour channel of the menu bar to `gain × value + offset`, kept between 0 and 1.
///
/// On a light wallpaper macOS lays a grey gradient over the black strip, and it may draw black
/// text. Windows cannot change either, so Nightbar redraws the menu bar through this remap: the
/// grey becomes black and the text becomes white.
struct ColorRemap: Equatable {
    let gain: Float
    let offset: Float

    /// For a light menu bar: black text over grey. Turns the text white and the grey black.
    static let lightMenuBar = Self(gain: -3.5, offset: 1)

    /// For a dark menu bar: white text over black. Turns faint grey up to 0.2 black and keeps the
    /// rest close to how macOS draws it.
    ///
    /// macOS lays no grey gradient over the strip under a dark menu bar, but its icons have grey
    /// parts, such as the empty part of the battery (about 0.45). A steeper remap would turn them
    /// black too and leave only the white parts.
    static let darkMenuBar = Self(gain: 1.25, offset: -0.25)

    static func forMenuBar(isDark: Bool) -> Self {
        isDark ? .darkMenuBar : .lightMenuBar
    }

    /// The new value of one colour channel, from 0 to 1.
    func apply(_ value: Float) -> Float {
        min(max(gain * value + offset, 0), 1)
    }

    /// The remap as a 4 × 5 colour matrix, row by row: red, green, blue, alpha. Alpha stays as is.
    var matrix: [Float] {
        [
            gain, 0, 0, 0, offset,
            0, gain, 0, 0, offset,
            0, 0, gain, 0, offset,
            0, 0, 0, 1, 0,
        ]
    }
}
