# AppKitBackend

SwiftCrossUI's native macOS backend built on top of AppKit.

@Metadata {
    @TitleHeading("Backend")
    @Available(macOS, introduced: "10.15")
}

## Overview

`AppKitBackend` is the default backend on macOS, supports all current SwiftCrossUI features, and
targets macOS 10.15+. It doesn't have any system dependencies other than a few system frameworks
included on all Macs.

## Usage

@TabNavigator {
    @Tab("Package.swift") {
        ```swift
        // ...
        let package = Package(
            // ...
            targets: [
                // ...
                .executableTarget(
                    name: "YourApp",
                    dependencies: [
                        .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                        .product(name: "AppKitBackend", package: "swift-cross-ui"),
                    ]
                ),
                // ...
            ],
            // ...
        )
        ```
    }
    @Tab("YourApp.swift") {
        ```swift
        import SwiftCrossUI
        import AppKitBackend
        
        @main
        struct YourApp: App {
            // You can explicitly initialize your app's chosen backend if you desire.
            // This happens automatically when you import any of the built-in backends.
            //
            // var backend = AppKitBackend()
            
            var body: some Scene {
                WindowGroup {
                    Text("Hello, World!")
                        .padding()
                }
            }
        }
        ```
    }
}
