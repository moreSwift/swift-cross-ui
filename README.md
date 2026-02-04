<p align="center">
    <img width="100%" src="banner.png">
</p>

<p align="center">
    <a href="https://github.com/moreSwift/swift-cross-ui/actions/workflows/build-test-and-docs.yml"><img alt="Workflow status" src="https://github.com/moreSwift/swift-cross-ui/actions/workflows/build-test-and-docs.yml/badge.svg?event=push"></a>
    <img alt="License" src="https://img.shields.io/github/license/moreSwift/swift-cross-ui">
    <a href="https://moreswift.dev/discord"><img src="https://img.shields.io/discord/1123965445687484466?color=6A7EC2&label=discord&logo=discord&logoColor=ffffff"></a> 
</p>

A SwiftUI-like framework for creating cross-platform apps in Swift (5.10+).

To get started with SwiftCrossUI, check out [the quick start guide](https://docs.swiftcrossui.dev/documentation/swiftcrossui/quick-start).

> [!NOTE]
> SwiftCrossUI does not attempt to replicate SwiftUI's API perfectly since that would be a constantly-moving target and SwiftUI has many entrenched Apple-centric concepts. That said, SwiftCrossUI's built-in views and scenes share much of their API surface with their SwiftUI cousins, and over time SwiftCrossUI will likely adopt many of SwiftUI's commonly-used APIs.

## Overview

- [Community](#community)
- [Supporting SwiftCrossUI](#supporting-swiftcrossui)
- [Documentation](#documentation)
- [Basic example](#basic-example)
- [Backends](#backends)

## Community

Discussion about SwiftCrossUI happens in the [moreSwift Discord server](https://moreswift.dev/discord). [Join](https://moreswift.dev/discord) to discuss the library, get involved, or just be kept up-to-date on progress!

## Supporting SwiftCrossUI

If you find SwiftCrossUI useful, please consider supporting its development by [becoming a sponsor](https://github.com/sponsors/stackotter). I spend most of my spare time working on open-source projects, and each sponsorship helps me focus more time on making high quality libraries and tools for the community.

## Documentation

Here's the [documentation site](https://docs.swiftcrossui.dev/documentation/swiftcrossui). SwiftCrossUI is still a work-in-progress; proper documentation and tutorials are on the horizon. Documentation contributions are very welcome!

## Basic example

Here's a simple example app demonstrating how easy it is to get started with SwiftCrossUI. For a more detailed walkthrough, check out our [quick start guide](https://docs.swiftcrossui.dev/documentation/swiftcrossui/quick-start)

```swift
import PackageDescription

let package = Package(
    name: "YourApp",
    dependencies: [
        .package(url: "https://github.com/moreSwift/swift-cross-ui", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "YourApp",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
            ]
        )
    ]
)
```
Figure 1: *Package.swift*

```swift
import SwiftCrossUI
import DefaultBackend

@main
struct YourApp: App {
    @State var count = 0

    var body: some Scene {
        WindowGroup("YourApp") {
            HStack {
                Button("-") { count -= 1 }
                Text("Count: \(count)")
                Button("+") { count += 1 }
            }.padding()
        }
    }
}
```
Figure 2: *Sources/YourApp/YourApp.swift*

## More examples

The SwiftCrossUI repository contains the above example and many more. The documentation hosts [a detailed list of all examples](https://docs.swiftcrossui.dev/documentation/swiftcrossui/examples).

Running the examples requires [Swift Bundler](https://github.com/moreSwift/swift-bundler), which provides consistent behavior across platforms and enables running on iOS/tvOS devices and simulators.

To install Swift Bundler, follow [its official installation instructions](https://github.com/moreSwift/swift-bundler?tab=readme-ov-file#installation-).

```sh
git clone https://github.com/moreSwift/swift-cross-ui
cd swift-cross-ui/Examples

# Run on host machine
swift-bundler run CounterExample
# Run on a connected device with "iPhone" in its name (macOS only)
swift-bundler run CounterExample --device iPhone
# Run on a simulator with "iPhone 16" in its name (macOS only)
swift-bundler run CounterExample --simulator "iPhone 16"
```

These examples may also be run using SwiftPM. However, resources may not be loaded as expected, and features such as deep linking may not work. You also won't be able to run the examples on iOS or tvOS using this method.

```sh
# Non-recommended method
swift run CounterExample
```

## Backends

SwiftCrossUI has a variety of backends tailored to different operating systems. The beauty of SwiftCrossUI is that you can write your app once and have it look native everywhere. For this reason I recommend using [DefaultBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/defaultbackend) unless you've got particular constraints.

> [!TIP]
> Click through each backend name for detailed system requirements and installation instructions.

- [DefaultBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/defaultbackend): Adapts to your target operating system. On macOS it uses [AppKitBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/appkitbackend), on Windows it uses [WinUIBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/winuibackend), on Linux it uses [GtkBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/gtkbackend), and on iOS and tvOS it uses [UIKitBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/uikitbackend).
- [AppKitBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/appkitbackend): The native macOS backend. Supports all SwiftCrossUI features.
- [UIKitBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/uikitbackend): The native iOS & tvOS backend. Supports most SwiftCrossUI features.
- [WinUIBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/winuibackend): The native Windows backend. Supports most SwiftCrossUI features.
- [GtkBackend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/gtkbackend): Works on Linux, macOS, and Windows. Requires gtk 4 to be installed. Supports most SwiftCrossUI features.
- [Gtk3Backend](https://docs.swiftcrossui.dev/documentation/swiftcrossui/gtk3backend): Exists to target older Linux distributions. Requires gtk 3 to be installed. Supports most SwiftCrossUI features. Quite buggy on macOS due to underlying Gtk 3 bugs.

> [!TIP]
> If you're using DefaultBackend, you can override the underlying backend during compilation by setting the `SCUI_DEFAULT_BACKEND` environment variable to the name of the desired backend. This is useful when you e.g. want to test the Gtk version of your app while using a Mac. Note that this only works for built-in backends and still requires the chosen backend to be compatible with your machine.
