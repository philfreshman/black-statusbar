import AppKit

/// The Nightbar mark, drawn for the menu bar.
///
/// It is the thunder N from the website: two stems joined by a diagonal that breaks like a
/// lightning bolt. It is a template image, so it has no colour of its own. macOS tints it white
/// on a dark menu bar and black on a light one.
///
/// The mark fills the image but for a point on each side, so it is about as tall as the icons
/// next to it. All sizes are in points.
enum MenuBarIcon {
    private static let size = NSSize(width: 16, height: 16)

    /// The square the mark fills.
    private static let markFrame = CGRect(x: 1, y: 1, width: 14, height: 14)

    /// The side of the square grid the outline is drawn on.
    private static let gridSize: CGFloat = 24

    /// The mark's outline on the grid, from the top left. It is `markPath` in
    /// website/src/icons.ts, moved to the grid's origin (there it sits 4 units into a 32 unit box).
    private static let outline: [CGPoint] = [
        CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 0),
        CGPoint(x: 14, y: 9), CGPoint(x: 14, y: 12.5),
        CGPoint(x: 19, y: 17.5), CGPoint(x: 19, y: 0),
        CGPoint(x: 24, y: 0), CGPoint(x: 24, y: 24),
        CGPoint(x: 19, y: 24), CGPoint(x: 10, y: 15),
        CGPoint(x: 10, y: 11.5), CGPoint(x: 5, y: 6.5),
        CGPoint(x: 5, y: 24), CGPoint(x: 0, y: 24),
    ]

    /// A new template image of the mark, for the status item's button.
    static func make() -> NSImage {
        let image = NSImage(size: size, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            drawMark(in: context)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Nightbar"
        return image
    }

    /// Converts a point on the grid to a point in the image.
    static func imagePoint(onGrid point: CGPoint) -> CGPoint {
        let scale = markFrame.width / gridSize
        return CGPoint(x: markFrame.minX + point.x * scale, y: markFrame.minY + point.y * scale)
    }

    private static func drawMark(in context: CGContext) {
        context.addLines(between: outline.map(imagePoint(onGrid:)))
        context.closePath()
        context.setFillColor(.black)
        context.fillPath()
    }
}
