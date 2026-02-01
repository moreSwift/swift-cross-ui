// swift-tools-version: 5.10

import Foundation
import PackageDescription

var exampleDependencies: [Target.Dependency] = [
    .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
    .product(name: "DefaultBackend", package: "swift-cross-ui"),
]
var hotReloadingDependencies: [Package.Dependency] = []

// The Swift Bundler runtime requires Swift >=6.0
#if compiler(>=6.0)
    hotReloadingDependencies = [
        .package(
            url: "https://github.com/moreSwift/swift-bundler",
            revision: "5d2ecbc11df78e56afeab0621c43d8e898dae98e"
        )
    ]
    exampleDependencies.append(
        .product(
            name: "SwiftBundlerRuntime",
            package: "swift-bundler",
            condition: .when(platforms: [.macOS, .linux])
        )
    )
#endif

let package = Package(
    name: "Examples",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .macCatalyst(.v13)],
    dependencies: [
        .package(name: "swift-cross-ui", path: ".."),
    ] + hotReloadingDependencies,
    targets: [
        .executableTarget(
            name: "ControlsExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "CounterExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "RandomNumberGeneratorExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "WindowingExample",
            dependencies: exampleDependencies,
            resources: [.copy("Banner.png")]
        ),
        .executableTarget(
            name: "GreetingGeneratorExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "NavigationExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "SplitExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "SpreadsheetExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "StressTestExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "NotesExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "PathsExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "WebViewExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "HoverExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "ForEachExample",
            dependencies: exampleDependencies
        ),
        .executableTarget(
            name: "AdvancedCustomizationExample",
            dependencies: exampleDependencies,
            resources: [.copy("Banner.png")]
        ),
        .executableTarget(
            name: "ColorsExample",
            dependencies: exampleDependencies
        )
    ]
)
