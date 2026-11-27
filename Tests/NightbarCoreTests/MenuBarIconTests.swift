import AppKit
import Testing

@testable import NightbarCore

struct MenuBarIconTests {
    private let scale: CGFloat = 4

    @Test func isTemplateSoMacOSCanTintIt() {
        #expect(MenuBarIcon.make().isTemplate)
    }

    @Test func isAsTallAsOtherMenuBarIcons() {
        #expect(MenuBarIcon.make().size == NSSize(width: 16, height: 16))
    }

    /// Points on the mark's 24 unit grid, from the top left.
    @Test(arguments: [
        CGPoint(x: 2.5, y: 20),  // left stem
        CGPoint(x: 21.5, y: 4),  // right stem
        CGPoint(x: 12, y: 10),  // the diagonal, where it breaks
    ])
    func fillsTheN(at point: CGPoint) throws {
        #expect(try alpha(atGrid: point) > 0.5)
    }

    @Test(arguments: [
        CGPoint(x: 12, y: 3),  // above the diagonal
        CGPoint(x: 12, y: 22),  // below the diagonal
    ])
    func leavesGapsBetweenTheStems(at point: CGPoint) throws {
        #expect(try alpha(atGrid: point) < 0.1)
    }

    private func alpha(atGrid point: CGPoint) throws -> CGFloat {
        let bitmap = try render(MenuBarIcon.make())
        let imagePoint = MenuBarIcon.imagePoint(onGrid: point)
        return alpha(in: bitmap, x: imagePoint.x, y: imagePoint.y)
    }

    private func render(_ image: NSImage) throws -> NSBitmapImageRep {
        let bitmap = try #require(
            NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(image.size.width * scale), pixelsHigh: Int(image.size.height * scale),
                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
            ))
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        image.draw(in: NSRect(x: 0, y: 0, width: bitmap.pixelsWide, height: bitmap.pixelsHigh))
        NSGraphicsContext.restoreGraphicsState()
        return bitmap
    }

    /// Takes a point in the icon's own coordinates; bitmap rows count from the top, like the icon.
    private func alpha(in bitmap: NSBitmapImageRep, x: CGFloat, y: CGFloat) -> CGFloat {
        bitmap.colorAt(x: Int(x * scale), y: Int(y * scale))?.alphaComponent ?? 0
    }
}
