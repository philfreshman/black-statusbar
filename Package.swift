// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Nightbar",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "NightbarCore"),
        .executableTarget(name: "Nightbar", dependencies: ["NightbarCore"]),
        .testTarget(name: "NightbarCoreTests", dependencies: ["NightbarCore"]),
    ],
    swiftLanguageModes: [.v6]
)
