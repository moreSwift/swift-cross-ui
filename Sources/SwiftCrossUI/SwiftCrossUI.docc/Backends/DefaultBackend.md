# DefaultBackend

An adaptive backend which uses different backends under the hood depending on the target operating
system.

@Metadata {
    @TitleHeading("Backend")
}

## Overview

The beauty of SwiftCrossUI is that you can write your app once and have it look native everywhere.
For this reason we recommend using DefaultBackend unless you have particular constraints. It uses
<doc:AppKitBackend> on macOS, <doc:WinUIBackend> on Window, <doc:GtkBackend> on Linux, and
<doc:UIKitBackend> on iOS/tvOS.

> Tip: If you're using DefaultBackend, you can override the underlying backend during compilation by
> setting the `SCUI_DEFAULT_BACKEND` environment variable to the name of the desired backend. This
> is useful when you e.g. want to test the Gtk version of your app while using a Mac.
> 
> Note that this only works for built-in backends and requires the chosen backend to be compatible
> with your machine.

> Note: When using `SCUI_DEFAULT_BACKEND` to switch underlying backends, you may encounter some
> linker-related missing symbol errors. These are caused by a SwiftPM bug and usually disappear if
> you run `swift package clean` before attempting to build your app again.

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
                        .product(name: "DefaultBackend", package: "swift-cross-ui"),
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
        import DefaultBackend
        
        @main
        struct YourApp: App {
            // You can explicitly initialize your app's chosen backend if you desire.
            // This happens automatically when you import any of the built-in backends.
            //
            // var backend = DefaultBackend()
            
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
