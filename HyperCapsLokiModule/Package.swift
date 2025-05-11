// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyperCapsLokiModule",
    platforms: [
      .macOS(.v14)
    ],
    products: [
        .library(
            name: "HyperCapsLokiModule",
            targets: ["HyperCapsLokiModule"]),
    ],
    dependencies: [
      .package(path: "../SharedAssets")
    ],
    targets: [
        .target(
            name: "HyperCapsLokiModule"),
        .testTarget(
            name: "Tests",
            dependencies: [
              "HyperCapsLokiModule",
              "SharedAssets"
            ]
        ),
    ]
)
