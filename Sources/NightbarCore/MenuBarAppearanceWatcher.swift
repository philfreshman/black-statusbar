import AppKit

/// An empty view inside Nightbar's menu bar icon. It reports when macOS switches the menu bar
/// between light and dark, which macOS decides from the wallpaper.
///
/// It keeps working while the icon is hidden.
final class MenuBarAppearanceWatcher: NSView {
    var onChange: ((_ isDark: Bool) -> Void)?

    var isDark: Bool {
        let match = effectiveAppearance.bestMatch(from: [.vibrantLight, .vibrantDark, .aqua, .darkAqua])
        return match == .vibrantDark || match == .darkAqua
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        onChange?(isDark)
    }
}
