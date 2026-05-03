# WinUIBackend

SwiftCrossUI's native Windows backend built on top of WinUI 3.

@Metadata {
    @TitleHeading("Backend")
    @Available(Windows, introduced: "10")
}

## Overview

WinUIBackend supports both arm64 and x64 Windows 10/11 computers. It is the recommended backend to
use when compiling SwiftCrossUI apps for Windows, as it aims to provide the most native experience.

## System dependencies

Before you can use WinUIBackend you must install two dependencies; the former is only required at
compile time while the later is only required at runtime.

> Important: If you're developing an app, you need to install **both** dependencies.

1. Install Windows SDK 10.0.17763:
   ```shell
   > winget install --id Microsoft.WindowsSDK.10.0.17763
   ```

   > Note: There was a typo in the version number on older versions of Windows; if installing
   > version 17763 doesn't work for you, try 177**36**.
2. Install the WindowsAppSDK 1.5.240205001-preview1 variant for your architecture: [x64]/[arm64]

[x64]: https://aka.ms/windowsappsdk/1.5/1.5.240205001-preview1/windowsappruntimeinstall-x64.exe
[arm64]: https://aka.ms/windowsappsdk/1.5/1.5.240205001-preview1/windowsappruntimeinstall-arm64.exe

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
                        .product(name: "WinUIBackend", package: "swift-cross-ui"),
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
    }
}
