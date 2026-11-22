// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "BlackMenuBar",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "BlackMenuBarCore"),
        .executableTarget(name: "BlackMenuBar", dependencies: ["BlackMenuBarCore"]),
        .testTarget(name: "BlackMenuBarCoreTests", dependencies: ["BlackMenuBarCore"]),
    ],
    swiftLanguageModes: [.v5]
)
