import AppKit

/// Draws one black screen corner. The rest of the view stays clear.
final class CornerView: NSView {
    private let corner: ScreenCorner
    private let radius: CGFloat

    init(corner: ScreenCorner, radius: CGFloat) {
        self.corner = corner
        self.radius = radius
        super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func draw(_: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.addPath(corner.blackShape(radius: radius))
        context.setFillColor(.black)
        context.fillPath()
    }
}
