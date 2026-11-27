import CoreGraphics

/// How round the black corners of the screen are.
enum CornerRadius: String, CaseIterable {
    case off, low, mid, high

    static let standard = CornerRadius.off

    /// The radius of the corner's curve in points.
    var points: CGFloat {
        switch self {
        case .off: 0
        case .low: 6
        case .mid: 10
        case .high: 16
        }
    }

    var title: String {
        switch self {
        case .off: "Off"
        case .low: "Low"
        case .mid: "Mid"
        case .high: "High"
        }
    }
}

/// One of the four corners of the screen area below the menu bar.
///
/// Each corner is a small black square with a quarter circle cut out of it, so the area below
/// the menu bar looks like a rounded rectangle. The top corners hang just below the menu bar and
/// join the black strip behind it. The bottom corners sit on the bottom edge of the screen.
enum ScreenCorner: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight

    private var isLeft: Bool { self == .topLeft || self == .bottomLeft }
    private var isTop: Bool { self == .topLeft || self == .topRight }

    /// The square the corner fills, in screen coordinates.
    func frame(screenFrame: CGRect, menuBarHeight: CGFloat, radius: CGFloat) -> CGRect {
        CGRect(
            x: isLeft ? screenFrame.minX : screenFrame.maxX - radius,
            y: isTop ? screenFrame.maxY - menuBarHeight - radius : screenFrame.minY,
            width: radius,
            height: radius
        )
    }

    /// The black part of the corner, in a square of side `radius` with its origin at the bottom left.
    ///
    /// It runs along the two square edges that meet at the screen's corner, then curves back
    /// along a quarter circle centred on the square's opposite corner.
    func blackShape(radius: CGFloat) -> CGPath {
        let outerCorner = CGPoint(x: isLeft ? 0 : radius, y: isTop ? radius : 0)
        let verticalNeighbour = CGPoint(x: outerCorner.x, y: radius - outerCorner.y)
        let horizontalNeighbour = CGPoint(x: radius - outerCorner.x, y: outerCorner.y)

        let path = CGMutablePath()
        path.move(to: verticalNeighbour)
        path.addLine(to: outerCorner)
        path.addLine(to: horizontalNeighbour)
        path.addArc(tangent1End: outerCorner, tangent2End: verticalNeighbour, radius: radius)
        path.closeSubpath()
        return path
    }
}
