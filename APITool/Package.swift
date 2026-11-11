// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "APITool",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.0"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit", from: "0.8.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
    ],
    targets: [
        .executableTarget(
            name: "APITool",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
