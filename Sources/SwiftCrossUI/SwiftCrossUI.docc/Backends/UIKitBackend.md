# UIKitBackend

SwiftCrossUI's native iOS and tvOS backend built on top of UIKit.

@Metadata {
    @TitleHeading("Backend")
    @Available(iOS, introduced: "13")
    @Available(tvOS, introduced: "13")
    @Available(visionOS, introduced: "1")
}

## Overview

`UIKitBackend` is the default backend on iOS, tvOS, and visionOS, supports most current
SwiftCrossUI features on iOS at least, and targets iOS/tvOS 13+ and all versions of visionOS. It
doesn't have any system dependencies other than a few system frameworks included on all
iOS/tvOS/visionOS devices.

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
                        .product(name: "UIKitBackend", package: "swift-cross-ui"),
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
        import UIKitBackend
        
        @main
        struct YourApp: App {
            // You can explicitly initialize your app's chosen backend if you desire.
            // This happens automatically when you import any of the built-in backends.
            //
            // var backend = UIKitBackend()
            //
            // You can register a custom UIApplicationDelegate by subclassing
            // UIKitBackend.ApplicationDelegate and providing it to UIKitBackend
            // via the alternate initializer.
            //
            // var backend = UIKitBackend(appDelegateClass: YourAppDelegate.self)
            
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
