/// Changes every colour channel of the menu bar to `gain × value + offset`, kept between 0 and 1.
///
/// On a light wallpaper macOS lays a grey gradient over the black strip, and it may draw black
/// text. Windows cannot change either, so Nightbar redraws the menu bar through this remap: the
/// grey becomes black and the text becomes white.
struct ColorRemap: Equatable {
    let gain: Float
    let offset: Float

    /// For a light menu bar: black text over grey. Turns the text white and the grey black.
    static let lightMenuBar = ColorRemap(gain: -3.5, offset: 1)

    /// For a dark menu bar: white text over black or grey. Keeps the text white, turns the grey black.
    static let darkMenuBar = ColorRemap(gain: 2, offset: -1)

    static func forMenuBar(isDark: Bool) -> ColorRemap {
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
