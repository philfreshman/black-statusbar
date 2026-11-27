import AppKit
import QuartzCore

/// Shows whatever lies behind its window, with a `ColorRemap` applied.
///
/// AppKit has no public way to filter what lies behind a window. This view uses Core Animation's
/// private backdrop layer and colour matrix filter, the same parts macOS uses for its own blur
/// and vibrancy. If a future macOS removes them, the view stays empty and the menu bar looks as
/// macOS draws it.
final class ColorRemapView: NSView {
    var remap: ColorRemap {
        didSet { applyRemap() }
    }

    private let backdrop = ColorRemapView.makeBackdropLayer()

    init(remap: ColorRemap) {
        self.remap = remap
        super.init(frame: .zero)
        wantsLayer = true
        if let backdrop {
            backdrop.frame = bounds
            backdrop.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            layer?.addSublayer(backdrop)
        }
        applyRemap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func applyRemap() {
        guard let backdrop, let filter = Self.makeColorMatrixFilter(remap.matrix) else { return }
        backdrop.filters = [filter]
    }

    /// A layer that shows what lies behind its window, including other apps' windows.
    private static func makeBackdropLayer() -> CALayer? {
        guard let backdropClass = NSClassFromString("CABackdropLayer") as? CALayer.Type else { return nil }
        let backdrop = backdropClass.init()
        backdrop.setValue(true, forKey: "windowServerAware")
        return backdrop
    }

    private static func makeColorMatrixFilter(_ matrix: [Float]) -> NSObject? {
        let makeFilter = NSSelectorFromString("filterWithType:")
        guard
            let filterClass = NSClassFromString("CAFilter") as? NSObject.Type,
            filterClass.responds(to: makeFilter),
            let filter = filterClass.perform(makeFilter, with: "colorMatrix")?.takeUnretainedValue() as? NSObject
        else { return nil }

        var values = matrix
        let colorMatrix = NSValue(bytes: &values, objCType: "{CAColorMatrix=ffffffffffffffffffff}")
        filter.setValue(colorMatrix, forKey: "inputColorMatrix")
        return filter
    }
}
