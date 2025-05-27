// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyperCapsLokiUI",
    platforms: [
      .macOS(.v14)
    ],
    products: [
        .library(
            name: "HyperCapsLokiUI",
            targets: ["HyperCapsLokiUI"])
    ],
    dependencies: [
      .package(path: "../HyperCapsLokiModule"),
      .package(path: "../SharedAssets")
    ],
    targets: [
        .target(
            name: "HyperCapsLokiUI",
            dependencies: [
              "HyperCapsLokiModule",
              "SharedAssets"
            ],
            path: ".",
            sources: ["Presentation"]
        )
    ]
)
