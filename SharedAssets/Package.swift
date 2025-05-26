// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedAssets",
    platforms: [
      .macOS(.v14)
    ],
    products: [
        .library(
            name: "SharedAssets",
            targets: ["SharedAssets"]),
    ],
    targets: [
        .target(
            name: "SharedAssets",
            path: "."
        ),
    ]
)
