# AndroidBackend

SwiftCrossUI's Android backend built on top of Android Views.

@Metadata {
    @TitleHeading("Backend")
    @Available(Android, introduced: "30")
}

## Overview

Android Views has been the standard UI framework for native Android development for a long time, only recently being superseded by Jetpack Compose. SwiftCrossUI has stuck with Android Views, because it is significantly easier to build SwiftCrossUI on top of imperative UI frameworks (compared to declarative frameworks).

Building SwiftCrossUI apps for Android is currently only officially supported on macOS, but this is a tooling issue rather than a technical reason. There's no reason that Swift Bundler couldn't target Android from Linux or Windows hosts. If someone has the motivation and time, support for Linux and Windows hosts could be knocked out pretty quickly.

## System dependencies

Before you can use `AndroidBackend` you must install the required dependencies;

- Swift dependencies ([guide](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html)):
  - an open source Swift toolchain, and
  - a Swift Android SDK matching the Swift toolchain version exactly
- Swift Bundler dependencies:
  - Android Studio ([download](https://developer.android.com/studio)), and
  - Android Studio cmdline-tools ([guide](https://stackoverflow.com/a/68492909/8268001))

[Getting Started with the Swift SDK for Android](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html) walks you through the step-by-step process for installing the required Swift toolchain and Swift Android SDK.

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
                        .product(name: "AndroidBackend", package: "swift-cross-ui"),
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
        import AndroidBackend
        
        @main
        struct YourApp: App {
            // You can explicitly initialize your app's chosen backend if you desire.
            // This happens automatically when you import any of the built-in backends.
            //
            // var backend = AndroidBackend()
            //
            // If you want to hook into your Android app's lifecycle methods you can
            // provide your own ActivityDelegate.
            //
            // var backend = AndroidBackend(delegate: MyActivityDelegate())
            
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

### Running on a device/simulator

Running your application requires [Swift Bundler](https://github.com/moreSwift/swift-bundler).

```sh
# List available Android devices
swift-bundler devices list --os android

# Run on your device
swift-bundler run --device "Your Device"

# List available Android emulators
swift-bundler simulators list --os android

# Run on your emulator
swift-bundler run --simulator "Your Simulator"
```
