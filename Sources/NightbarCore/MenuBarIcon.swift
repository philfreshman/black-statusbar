import AppKit

/// The Nightbar window, drawn for the menu bar.
///
/// It matches the app icon: a rounded window frame with a solid bar across the top, which
/// stands for the black menu bar Nightbar draws. It is a template image, so it has no colour
/// of its own. macOS tints it white on a dark menu bar and black on a light one.
///
/// The image is a little wider than it is tall, so the window is about as tall as the icons
/// next to it. All sizes are in points.
enum MenuBarIcon {
    static let size = NSSize(width: 20, height: 16)

    static let window = CGRect(x: 1, y: 1, width: 18, height: 14)
    static let topBarHeight: CGFloat = 4.6
    private static let cornerRadius: CGFloat = 3.4
    private static let frameLineWidth: CGFloat = 1.7

    static func make() -> NSImage {
        let image = NSImage(size: size, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            drawTopBar(in: context)
            drawFrame(in: context)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Nightbar"
        return image
    }

    /// Fills the top of the window, clipped to its rounded corners.
    private static func drawTopBar(in context: CGContext) {
        context.saveGState()
        context.addPath(roundedPath(window, radius: cornerRadius))
        context.clip()
        context.setFillColor(.black)
        context.fill(CGRect(x: window.minX, y: window.minY, width: window.width, height: topBarHeight))
        context.restoreGState()
    }

    /// Strokes the frame just inside the window's outline, so its outer edge is the window edge.
    private static func drawFrame(in context: CGContext) {
        let inset = frameLineWidth / 2
        context.addPath(roundedPath(window.insetBy(dx: inset, dy: inset), radius: cornerRadius - inset))
        context.setLineWidth(frameLineWidth)
        context.setStrokeColor(.black)
        context.strokePath()
    }

    private static func roundedPath(_ rect: CGRect, radius: CGFloat) -> CGPath {
        CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    }
}
