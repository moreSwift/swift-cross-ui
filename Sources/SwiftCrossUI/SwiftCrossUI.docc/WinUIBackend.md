# WinUIBackend

SwiftCrossUI's native Windows backend built on top of WinUI 3.

## Overview

WinUIBackend supports both ARM64 and x64 Windows 10/11 computers. It is the recommended backend to use when compiling SwiftCrossUI apps for Windows, as it aims to provide the most native experience.

## System dependencies

Before you can use WinUIBackend you must install two dependencies; the former is only required at compile time while the later is only required at runtime.

1. Install Windows SDK 10.0.17736;
   ```sh
   winget install --id Microsoft.WindowsSDK.10.0.17736
   ```
2. Install the WindowsAppSDK 1.5.240205001-preview1 variant for your architecture; [x64](https://aka.ms/windowsappsdk/1.5/1.5.240205001-preview1/windowsappruntimeinstall-x64.exe)/[arm64](https://aka.ms/windowsappsdk/1.5/1.5.240205001-preview1/windowsappruntimeinstall-arm64.exe)

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
        .product(name: "WinUIBackend", public: "swift-cross-ui"),
      ]
    )
    ...
  ]
  ...
)
```
Figure 1: *adding `WinUIBackend` to an executable target*

```swift
import SwiftCrossUI
import WinUIBackend

@main
struct YourApp: App {
  // You can explicitly initialize your app's chosen backend if you desire.
  // This happens automatically when you import any of the built-in backends.
  //
  // var backend = WinUIBackend()

  var body: some Scene {
    WindowGroup {
      Text("Hello, World!")
        .padding()
    }
  }
}
```
Figure 2: *using `WinUIBackend`*
