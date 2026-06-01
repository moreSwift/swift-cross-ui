# UIKitBackend

SwiftCrossUI's native iOS and tvOS backend built on top of UIKit.

## Overview

`UIKitBackend` is the default backend on iOS and tvOS, supports most current SwiftCrossUI features on iOS at least, and targets iOS/tvOS 13+. It doesn't have any system dependencies other than a few system frameworks included on all iOS/tvOS devices.

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
        .product(name: "UIKitBackend", public: "swift-cross-ui"),
      ]
    )
    ...
  ]
  ...
)
```
Figure 1: *adding `UIKitBackend` to an executable target*

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
Figure 2: *using `UIKitBackend`*
