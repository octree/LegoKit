// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LegoKit",
    platforms: [
        .macCatalyst(.v14),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LegoKit",
            targets: ["LegoKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LegoKit",
            dependencies: []
        ),
        .testTarget(
            name: "LegoKitTests",
            dependencies: ["LegoKit"]
        )
    ]
)
