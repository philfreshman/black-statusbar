import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum WallpaperComposerError: LocalizedError {
    case unreadableImage(URL)
    case cannotCreateCanvas
    case cannotWrite(URL)

    public var errorDescription: String? {
        switch self {
        case .unreadableImage(let url): "Can't read wallpaper \(url.lastPathComponent)"
        case .cannotCreateCanvas: "Can't create the image canvas"
        case .cannotWrite(let url): "Can't save \(url.lastPathComponent)"
        }
    }
}

/// Builds a copy of a wallpaper with a solid black band where the menu bar sits.
///
/// macOS picks the menu bar icon colour from the wallpaper underneath it. A black band
/// therefore gives a black menu bar with white icons and text.
public struct WallpaperComposer: Sendable {
    public init() {}

    public func render(wallpaper source: URL, to destination: URL, canvasSize: CGSize, barHeight: Int) throws {
        let image = try loadImage(at: source)
        let composed = try compose(image, canvasSize: canvasSize, barHeight: barHeight)
        try writePNG(composed, to: destination)
    }

    public func compose(_ source: CGImage, canvasSize: CGSize, barHeight: Int) throws -> CGImage {
        let width = Int(canvasSize.width)
        let height = Int(canvasSize.height)
        let context = try makeCanvas(width: width, height: height, preferredColorSpace: source.colorSpace)

        context.interpolationQuality = .high
        let imageSize = CGSize(width: source.width, height: source.height)
        context.draw(source, in: Self.aspectFillRect(imageSize: imageSize, canvasSize: canvasSize))

        // Core Graphics puts the origin at the bottom left, so the top band starts at height - barHeight.
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: height - barHeight, width: width, height: barHeight))

        guard let composed = context.makeImage() else { throw WallpaperComposerError.cannotCreateCanvas }
        return composed
    }

    /// Mirrors the "Fill Screen" wallpaper option: scale to cover the canvas, keep the
    /// aspect ratio, centre the image and crop whatever overflows.
    static func aspectFillRect(imageSize: CGSize, canvasSize: CGSize) -> CGRect {
        let scale = max(canvasSize.width / imageSize.width, canvasSize.height / imageSize.height)
        let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: (canvasSize.width - scaledSize.width) / 2,
            y: (canvasSize.height - scaledSize.height) / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )
    }

    private func makeCanvas(width: Int, height: Int, preferredColorSpace: CGColorSpace?) throws -> CGContext {
        let candidates = [preferredColorSpace, CGColorSpace(name: CGColorSpace.sRGB)]
            .compactMap { $0 }
            .filter { $0.model == .rgb }

        for colorSpace in candidates {
            if let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            ) {
                return context
            }
        }
        throw WallpaperComposerError.cannotCreateCanvas
    }

    private func loadImage(at url: URL) throws -> CGImage {
        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, CGImageSourceGetPrimaryImageIndex(source), nil)
        else {
            throw WallpaperComposerError.unreadableImage(url)
        }
        return image
    }

    /// Writes to a temporary file first, so macOS never picks up a half-written wallpaper.
    private func writePNG(_ image: CGImage, to destination: URL) throws {
        let temporary = destination.appendingPathExtension("partial")
        guard let target = CGImageDestinationCreateWithURL(
            temporary as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw WallpaperComposerError.cannotWrite(destination)
        }
        CGImageDestinationAddImage(target, image, nil)
        guard CGImageDestinationFinalize(target) else { throw WallpaperComposerError.cannotWrite(destination) }

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.moveItem(at: temporary, to: destination)
    }
}
