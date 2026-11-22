import AppKit
import Testing
@testable import NightbarCore

struct MenuBarIconTests {
    private let scale: CGFloat = 4

    @Test func isTemplateSoMacOSCanTintIt() {
        #expect(MenuBarIcon.make().isTemplate)
    }

    @Test func isAsTallAsOtherMenuBarIcons() {
        #expect(MenuBarIcon.make().size == NSSize(width: 20, height: 16))
    }

    @Test func drawsWindowWithSolidTopBar() throws {
        let bitmap = try render(MenuBarIcon.make())
        let window = MenuBarIcon.window

        #expect(alpha(in: bitmap, x: window.midX, y: window.minY + MenuBarIcon.topBarHeight / 2) > 0.5)
        #expect(alpha(in: bitmap, x: window.minX + 0.5, y: window.midY) > 0.5)
        #expect(alpha(in: bitmap, x: window.midX, y: window.midY + 2) < 0.1)
    }

    private func render(_ image: NSImage) throws -> NSBitmapImageRep {
        let bitmap = try #require(NSBitmapImageRep(
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
