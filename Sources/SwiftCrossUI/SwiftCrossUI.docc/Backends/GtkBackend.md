# GtkBackend

SwiftCrossUI's native Linux backend built on top of Gtk 4.

@Metadata {
    @TitleHeading("Backend")
    @Available(Gtk, introduced: "4")
}

## Overview

While Gtk isn't the preferred UI framework on every Linux distro, it's the closest thing
SwiftCrossUI has to a native Linux backend for now. The Qt backend may be brought back to life at
some point to cover the rest of Linux distros.

For targetting older, pre-Gtk-4 Linux distros, see the secondary <doc:Gtk3Backend>.

This backend supports Linux, macOS, and Windows, but its support for macOS has a few known issues
due to underlying bugs in Gtk (and its support for Windows isn't well tested).

## System dependencies

Before you can use `GtkBackend` you must install the required system dependencies for your platform.
Here are installation instructions tailored to each supported platform:

### Linux

Install the required dependencies using your system package manager:

@TabNavigator {
    @Tab("Debian-based distros") {
        ```shell
        $ sudo apt install libgtk-4-dev clang
        ```
    }
    @Tab("Fedora-based distros") {
        ```shell
        $ sudo dnf install gtk4-devel clang
        ```
    }
}

If you run into errors related to not finding `gtk/gtk.h` when trying to build a SwiftCrossUI
project, try restarting your computer. This has worked in some cases (although there may be a more
elegant solution).

If you are on a non-Debian, non-Fedora distro and the `GtkBackend` requirements end up differing
significantly from the requirements stated above, please open a GitHub issue or PR so that we can
improve the documentation.

### macOS

Install the required dependencies using Homebrew:

```shell
$ brew install pkg-config gtk4
```

If you don't have Homebrew, installation instructions can be found at [brew.sh](https://brew.sh).

It should also be possible to use `gtk4` installed via MacPorts, but we have not tested that.

If you run into errors related to `libffi` or `FFI` when trying to build a SwiftCrossUI project with
`GtkBackend`, which can occur when certain older versions of the Xcode Command Line Tools are
installed, try running the following command to patch libffi:

```shell
$ sed -i '' 's/-I..includedir.//g' $(brew --prefix)/Library/Homebrew/os/mac/pkgconfig/*/libffi.pc
```

### Windows

On Windows things are a bit complicated (as usual), so we only support installation via [vcpkg](https://github.com/microsoft/vcpkg). First, install vcpkg:

```shell
> git clone https://github.com/microsoft/vcpkg C:\vcpkg
> C:\vcpkg\bootstrap-vcpkg.bat
```

> Important: It's important to install vcpkg at the root of a drive due to limitations of the Gtk
> build system.

**After installation, make the following changes to your environment variables:**

1. Set the `PKG_CONFIG_PATH` environment variable to `C:\vcpkg\installed\x64-windows\lib\pkgconfig`.
   This is only required for building.
2. Add `C:\vcpkg\installed\x64-windows\bin` to your `Path` environment variable. This is only
   required for running.

With vcpkg installed, you have two options for Gtk installation; global installation, and
project-local installation.

#### Global Gtk 4 installation (recommended)

Installation can take 45+ minutes depending on your machine.

> Important: Run the chosen command at the root of your drive to ensure that vcpkg doesn't run in
> manifest mode.

@TabNavigator {
    @Tab("x64") {
        ```shell
        > cd C:\
        > C:\vcpkg\vcpkg.exe install gtk --triplet x64-windows
        ```
    }
    @Tab("arm64") {
        ```shell
        > cd C:\
        > C:\vcpkg\vcpkg.exe install gtk --triplet arm64-windows
        ```
    }
}

#### Project-local Gtk 4 installation (more unreliable)

> Note: If the absolute path to your project contains spaces, it is possible that vcpkg will break,
> and installing globally will be a more reliable strategy.

Create a file called `vcpkg.json` at the root of your project and make sure that it includes the
`gtk` dependency:

```json
{
    "name": "project-name",
    "version-string": "main",
    "dependencies": ["gtk"]
}
```

Then run the following command from your project root:

@TabNavigator {
    @Tab("x64") {
        ```shell
        > C:\vcpkg\vcpkg.exe install --triplet x64-windows
        ```
    }
    @Tab("arm64") {
        ```shell
        > C:\vcpkg\vcpkg.exe install --triplet arm64-windows
        ```
    }
}

#### Troubleshooting vcpkg

If vcpkg fails to build a package with an error along the lines of
`ninja: error: manifest 'build.ninja' still dirty after 100 tries`, then some of your vcpkg
installation may have been installed in the future according to Windows due to your VM's timezone
being set incorrectly. This can be resolved by running the following commands in Git Bash:

```shell
$ cd C:\vcpkg
$ find . -type f -exec touch {} +
```

If you have a fix that doesn't require Git Bash, feel free to
[open an issue](https://github.com/moreSwift/swift-cross-ui/issues/new/choose) or pull request with
your fix.

If you face a different issue, please open an issue or pull request to update this troubleshooting
section.

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
                        .product(name: "GtkBackend", package: "swift-cross-ui"),
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
        import GtkBackend
        
        @main
        struct YourApp: App {
            // You can explicitly initialize your app's chosen backend if you desire.
            // This happens automatically when you import any of the built-in backends.
            //
            // var backend = GtkBackend()
            //
            // If you aren't using Swift Bundler, you may have to explicitly provide
            // your app's identifier for some Gtk3Backend features to work correctly
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
    }
}
