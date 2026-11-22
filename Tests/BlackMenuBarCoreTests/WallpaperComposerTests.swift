import CoreGraphics
import Testing
@testable import BlackMenuBarCore

struct WallpaperComposerTests {
    private let black: [UInt8] = [0, 0, 0]
    private let white: [UInt8] = [255, 255, 255]

    @Test func paintsBlackBandAcrossTheTop() throws {
        let source = try makeSolidImage(width: 40, height: 20, gray: 1)

        let result = try WallpaperComposer().compose(source, canvasSize: CGSize(width: 80, height: 40), barHeight: 6)
        let pixels = try PixelReader(result)

        #expect(pixels.rgb(x: 0, yFromTop: 0) == black)
        #expect(pixels.rgb(x: 79, yFromTop: 5) == black)
    }

    @Test func keepsWallpaperBelowTheBand() throws {
        let source = try makeSolidImage(width: 40, height: 20, gray: 1)

        let result = try WallpaperComposer().compose(source, canvasSize: CGSize(width: 80, height: 40), barHeight: 6)
        let pixels = try PixelReader(result)

        #expect(pixels.rgb(x: 40, yFromTop: 6) == white)
        #expect(pixels.rgb(x: 79, yFromTop: 39) == white)
    }

    @Test func outputMatchesCanvasSize() throws {
        let source = try makeSolidImage(width: 30, height: 50, gray: 1)

        let result = try WallpaperComposer().compose(source, canvasSize: CGSize(width: 120, height: 60), barHeight: 4)

        #expect(result.width == 120)
        #expect(result.height == 60)
    }

    @Test func fillRectCoversCanvasAndKeepsAspectRatio() {
        let rect = WallpaperComposer.aspectFillRect(
            imageSize: CGSize(width: 100, height: 100), canvasSize: CGSize(width: 200, height: 100)
        )

        #expect(rect == CGRect(x: 0, y: -50, width: 200, height: 200))
    }
}

private enum TestImageError: Error {
    case cannotCreateContext
}

private func makeSRGBContext(width: Int, height: Int) throws -> CGContext {
    guard let context = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { throw TestImageError.cannotCreateContext }
    return context
}

private func makeSolidImage(width: Int, height: Int, gray: CGFloat) throws -> CGImage {
    let context = try makeSRGBContext(width: width, height: height)
    context.setFillColor(CGColor(gray: gray, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    guard let image = context.makeImage() else { throw TestImageError.cannotCreateContext }
    return image
}

/// Reads pixels of an image as 8-bit sRGB. Row 0 of the bitmap is the top of the image.
private struct PixelReader {
    private let bytes: [UInt8]
    private let width: Int

    init(_ image: CGImage) throws {
        let context = try makeSRGBContext(width: image.width, height: image.height)
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let buffer = context.data!.assumingMemoryBound(to: UInt8.self)
        bytes = Array(UnsafeBufferPointer(start: buffer, count: image.width * image.height * 4))
        width = image.width
    }

    func rgb(x: Int, yFromTop y: Int) -> [UInt8] {
        let offset = (y * width + x) * 4
        return Array(bytes[offset..<offset + 3])
    }
}
