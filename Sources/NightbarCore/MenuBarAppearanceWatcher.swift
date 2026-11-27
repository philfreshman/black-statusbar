import AppKit

/// An empty view inside Nightbar's menu bar icon. It reports when macOS switches the menu bar
/// between light and dark, which macOS decides from the wallpaper.
///
/// It keeps working while the icon is hidden.
final class MenuBarAppearanceWatcher: NSView {
    private let onChange: (_ isDark: Bool) -> Void

    var isDark: Bool {
        let match = effectiveAppearance.bestMatch(from: [.vibrantLight, .vibrantDark, .aqua, .darkAqua])
        return match == .vibrantDark || match == .darkAqua
    }

    /// `onChange` is called each time the menu bar switches between light and dark.
    init(onChange: @escaping (_ isDark: Bool) -> Void) {
        self.onChange = onChange
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        onChange(isDark)
    }
}
