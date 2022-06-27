// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TextTransformerSDK",
    platforms: [.macOS(.v13), .macCatalyst(.v16)],
    products: [
        .library(
            name: "TextTransformerSDK",
            targets: ["TextTransformerSDK"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TextTransformerSDK",
            dependencies: []),
    ]
)
