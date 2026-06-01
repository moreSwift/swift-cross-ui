# GtkBackend

SwiftCrossUI's native Linux backend built on top of Gtk 4.

## Overview

While Gtk isn't the preferred UI framework on every Linux distro, it's the closest thing SwiftCrossUI has to a native Linux backend for now. The Qt backend may be brought back to life at some point to cover the rest of Linux distros.

For targetting older pre Gtk 4 Linux distros, see the secondary <doc:Gtk3Backend>

This backend supports Linux, macOS, and Windows, but its support for macOS has a few known issues worse due to underlying Gtk issues (and its support for Windows isn't well tested).

## System dependencies

Before you can use `GtkBackend` you must install the required system dependencies for your platform. Here are installation instructions tailored to each supported platform;

### Linux

```sh
# Debian-based distros
sudo apt install libgtk-4-dev clang

# Fedora-based distros
sudo dnf install gtk4-devel clang
```
Figure 1: *installing the required dependencies on Debian-based and Fedora-based Linux distros*

If you run into errors related to not finding `gtk/gtk.h` when trying to build a swift-cross-ui project, try restarting your computer. This has worked in some cases (although there may be a more elegant solution).

If you are on a non-Debian non-Fedora distro and the `GtkBackend` requirements end up differing significantly from the requirements stated above, please open a GitHub issue or PR so that we can improve the documentation.

### macOS

```sh
brew install pkg-config gtk4
```
Figure 2: *installing the required dependencies using Homebrew*

If you don't have Homebrew, installation instructions can be found at [brew.sh](https://brew.sh).

It should also be possible to use `gtk4` installed via MacPorts, but I have not tested that.

If you run into errors related to `libffi` or `FFI` when trying to build a swift-cross-ui project with `GtkBackend`, which can occur when certain older versions of the Xcode Command Line Tools are installed, try running the following command to patch libffi:

```sh
sed -i '' 's/-I..includedir.//g' $(brew --prefix)/Library/Homebrew/os/mac/pkgconfig/*/libffi.pc
```
Figure 3: *fixing the `libffi` issue that some people face*

### Windows

On Windows things are a bit complicated (as usual), so we only support installation via [vcpkg](https://github.com/microsoft/vcpkg). First, install vcpkg;

```sh
git clone https://github.com/microsoft/vcpkg C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat
```
Figure 4: *install vcpkg (requires git cli)*

> Warning: It's important to install vcpkg at the root of a drive due to limitations of the Gtk build system.

**After installation, make the following changes to your environment variables:**

1. Set the `PKG_CONFIG_PATH` environment variable to `C:\vcpkg\installed\x64-windows\lib\pkgconfig`. This is only required for building.
2. Add `C:\vcpkg\installed\x64-windows\bin` to your `Path` environment variable. This is only required for running.

With vcpkg installed, you have two options for Gtk installation; global installation, and project-local installation

#### Global Gtk 4 installation (recommended)

Note that the command depends on your machine's architecture; choose between Figure 5 and Figure 6 accordingly.

Installation can take 45+ minutes depending on your machine.

```sh
C:\vcpkg\vcpkg.exe install gtk --triplet x64-windows
```
Figure 5: *install Gtk 4 globally on x64 Windows*

```sh
C:\vcpkg\vcpkg.exe install gtk --triplet arm64-windows
```
Figure 6: *install Gtk 4 globally on arm64 Windows*

> Warning: Run the chosen command at the root of your drive to ensure that vcpkg doesn't run in manifest mode.

#### Project-local Gtk 4 installation (more unreliable)

> Note: If the absolute path to your project contains spaces, it is possible that vcpkg will break, and installing globally will be a more reliable strategy.

To install Gtk 4 in a project-local dependency store you must setup a `vcpkg.json` manifest file and then run vcpkg, as detailed below;

First `vcpkg.json` at the root of your project and make sure that it includes the `gtk` dependency as demonstrated in Figure 7.

```json
{
    "name": "project-name",
    "version-string": "main",
    "dependencies": ["gtk"]
}
```
Figure 7: *an example `vcpkg.json` public manifest*

```sh
C:\vcpkg\vcpkg.exe install --triplet x64-windows
```
Figure 8: *install the dependencies listed in your public manifest*

> Warning: Replace the triplet with `arm64-windows` if you're on ARM64

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
Figure 9: *adding `GtkBackend` to an executable target*

```swift
import SwiftCrossUI
import GtkBackend

@main
struct YourApp: App {
  // You can explicitly initialize your app's chosen backend if you desire.
  // This happens automatically when you import any of the built-in backends.
  //
  // var backend = GtkBackend()
  //
  // If you aren't using Swift Bundler, you may have to explicitly provide
  // your app's identifier for some GtkBackend features to work correctly
  // (such as handling custom URL schemes).
  //
  // var backend = GtkBackend(appIdentifier: "com.example.YourApp")

  var body: some Scene {
    WindowGroup {
      Text("Hello, World!")
        .padding()
    }
  }
}
```
Figure 10: *using `GtkBackend`*
