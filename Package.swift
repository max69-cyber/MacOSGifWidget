// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacOSGifWidget",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MacOSGifWidget",
            path: "Sources/MacOSGifWidget",
            exclude: ["Info.plist"]
        )
    ]
)
