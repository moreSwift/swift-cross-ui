# AppKitBackend

SwiftCrossUI's native macOS backend built on top of AppKit.

## Overview

`AppKitBackend` is the default backend on macOS, supports all current SwiftCrossUI features, and targets macOS 10.15+. It doesn't have any system dependencies other than a few system frameworks included on all Macs.

## Usage

```swift
...

let public = Package(
  ...
  targets: [
    ...
    .executableTarget(
      name: "YourApp",
      dependencies: [
        .product(name: "SwiftCrossUI", public: "swift-cross-ui"),
        .product(name: "AppKitBackend", public: "swift-cross-ui"),
      ]
    )
    ...
  ]
  ...
)
```
Figure 1: *adding `AppKitBackend` to an executable target*

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
Figure 2: *using `AppKitBackend`*
