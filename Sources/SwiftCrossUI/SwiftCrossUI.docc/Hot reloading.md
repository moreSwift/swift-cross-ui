# Hot reloading

## Overview

SwiftCrossUI supports hot reloading when used together with Swift Bundler.
Currently this is only supported on macOS and Linux, but the macros work everywhere so
that you can safely leave them in even when unused.

## Setting up hot reloading

Setting up your app for hot reloading involves three main steps:

1. Making sure that [Swift Bundler](https://swiftbundler.dev) can build your project,
2. Importing the `SwiftBundlerRuntime`, and
3. Using the `@HotReloadable` and `#hotReloadable` macros to instrument your main app file

These are all once-off steps, and the effects of the instrumentation macros should be negligible when hot reloading is disabled.

### Making sure that Swift Bundler can build your project

If you're already using Swift Bundler for your project, then you can move on to [instrumenting your app](#instrumenting-your-app). Otherwise, follow [Swift Bundler's migration guide](https://swiftbundler.dev/documentation/swift-bundler/migrating-to-swift-bundler) before continuing.

### Instrumenting your app

SwiftCrossUI hot reloading currently involves a little bit of manual instrumentation. We believe that we'll be able to get rid of this step eventually, but we need a more consistent concept of scene identity before we can do that.

Instrumenting your app involves making three changes to your main app file;

1. Importing the `SwiftBundlerRuntime`,
2. Annotating your app with the ``HotReloadable`` macro, and
3. Wrapping your scene's content with the ``hotReloadable`` macro

Here's what that looks like in practice;

```swift
import DefaultBackend
import SwiftCrossUI
import SwiftBundlerRuntime // 1.

@main
@HotReloadable // 2.
struct MyApp: App {
  // ...

  var body: some Scene {
    WindowGroup("MyApp") {
      #hotReloadable { // 3.
        Text("This is my app!")
      }
    }
  }
}
```

> Note: Anything inside ``hotReloadable`` ("the hot reloading boundary") gets reloaded, and everything outside of it remaings unchanged across hot reloads.

> Important: The ``HotReloadable`` macro must be able to "see" the ``hotReloadable`` usage sites, so you cannot implement your app's body in an `extension`.

## Starting a hot reloading session

Now that your project supports hot reloading, lets take it for a spin!

```sh
swift-bundler run --hot
```

The initial build might take a little longer than a regular incremental build as SwiftPM rebuilds your app with hot reloading enabled, but once your session begins the incremental build times should return to what you've come to expect from SwiftPM.

Once your app has appeared, make a change to one of your app's source files. You should see your Swift Bundler terminal window show signs of a new build starting, and soon after you should see your changes reflected on screen.

> Note: Swift Bundler currently only observes your app's `Sources` directory. If you have custom source paths outside of the `Sources` directory, or if you want to edit files in local dependencies, you're out of luck for now. Please leave a comment on [moreSwift/swift-bundler#235](https://github.com/moreSwift/swift-bundler/issues/235) if this affects your use case.

## Persisting state across reloads

SwiftCrossUI can only persist state that conforms to [Codable](https://developer.apple.com/documentation/swift/codable). Otherwise SwiftCrossUI doesn't have a way to persist your state across reloads.

We may extend the state persistence feature to support non-`Codable` state using reflection in future, but that will have its limitations, and likely won't perform as well as `Codable` state persistence.

State that cannot be made `Codable` (such as an ongoing network connection) must be stored outside of your hot reloading boundary (which is what the ``hotReloadable`` macro marks). In other words, the source of truth for non-serializable state should be stored directly on your main app. [Environment objects](https://docs.swiftcrossui.dev/documentation/swiftcrossui/view/environment(_:)) are a great way to achieve that.

## Safe changes vs unsafe changes

Due to Swift being a compiled language, SwiftCrossUI can only give limited guarantees regarding the memory safety of a hot reloading application.

Unsafe changes include changing the memory layout of your `App` struct and changing the memory layouts of anything that your `App` struct references.

Safe changes include reordering properties on views, changing the body of a ``hotReloadable`` macro usage site, and adding new state properties.

> Note: Some safe changes may result in loss of state, because ``State`` falls back to its initial value when fails to deserialize a persisted state. The only semi-guarantee is that they won't cause memory safety issues.

## Topics

- ``HotReloadable()``
- ``hotReloadable(_:)``
