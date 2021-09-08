// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SLogOSBackend",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(
            name: "SLogOSBackend",
            targets: ["SLogOSBackend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stillyoungman/SLog.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SLogOSBackend",
            dependencies: [
                "SLog"
            ])
    ]
)
