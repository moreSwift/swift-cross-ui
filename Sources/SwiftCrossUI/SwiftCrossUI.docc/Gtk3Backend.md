# Gtk3Backend

A secondary Linux backend built on top of Gtk 3 (for older distros without Gtk 4).

## Overview

This backend supports Linux, macOS and Windows (maybe?), but its support for non-Linux platforms is significantly worse than <doc:GtkBackend>'s (due to underlying Gtk 3 issues). Even on Linux, it's recommended to use <doc:GtkBackend> over Gtk3Backend where possible.

> Warning: Non-Linux Gtk3Backend support is not a priority of this backend, and should only be used during development (e.g. to test your Linux UI natively on a Mac). There are multiple better choices of backend available on each non-Linux platform.

## System dependencies

Before you can use Gtk3Backend you must install the required system dependencies for your platform.

### Linux

```sh
sudo apt install libgtk-3-dev
```
Figure 1: *installing Gtk 3 dev on an apt-based Linux distro*

If you are on a non-apt distro and the Gtk3Backend requirements end up differing significantly from the requirements stated above, please open a GitHub issue or PR so that we can improve the documentation.

### macOS

```sh
brew install pkg-config gtk+3
```
Figure 2: *installing Gtk 3 using Homebrew*

If you don't have Homebrew, installation instructions can be found at [brew.sh](https://brew.sh).

It should also be possible to use `gtk3` installed via MacPorts, but I have not tested that.

### Windows

`gtk3` installation has not been tested on Windows, and neither has Gtk3Backend, although there shouldn't be anything to stop it from working (🤞). Follow the `gtk4` installation instructions from <doc:GtkBackend> and replace `gtk` with `gtk3` in any vcpkg commands or `vcpkg.json` manifest files.

If you try this on Windows open a GitHub issue (even if it works without changes) so that we can fix any issues you faced and update this documentation.

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
        .product(name: "GtkBackend", public: "swift-cross-ui"),
      ]
    )
    ...
  ]
  ...
)
```
Figure 3: *adding `Gtk3Backend` to an executable target*

```swift
import SwiftCrossUI
import Gtk3Backend

@main
struct YourApp: App {
  // You can explicitly initialize your app's chosen backend if you desire.
  // This happens automatically when you import any of the built-in backends.
  //
  // var backend = Gtk3Backend()
  //
  // If you aren't using Swift Bundler, you may have to explicitly provide
  // your app's identifier for some Gtk3Backend features to work correctly
  // (such as handling custom URL schemes).
  //
  // var backend = Gtk3Backend(appIdentifier: "com.example.YourApp")

  var body: some Scene {
    WindowGroup {
      Text("Hello, World!")
        .padding()
    }
  }
}
```
Figure 4: *using `Gtk3Backend`*
