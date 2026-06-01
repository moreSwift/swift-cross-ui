// swift-tools-version:5.6

import Foundation
import PackageDescription

// GTK 4.10+ detection
var gtkSwiftSettings: [SwiftSetting] = []
if let version = getGtk4MinorVersion(), version >= 10 {
    gtkSwiftSettings.append(.define("GTK_4_10_PLUS"))
}

// Default backend selection
let defaultBackend: String
if let backend = ProcessInfo.processInfo.environment["SCUI_DEFAULT_BACKEND"] {
    defaultBackend = backend
} else {
    #if os(macOS)
        defaultBackend = "AppKitBackend"
    #else
        defaultBackend = "GtkBackend"
    #endif
}

// Hot reloading check
let hotReloadingEnabled: Bool
hotReloadingEnabled =
    ProcessInfo.processInfo.environment["SWIFT_BUNDLER_HOT_RELOADING"] != nil
    || ProcessInfo.processInfo.environment["SCUI_HOT_RELOADING"] != nil

// Library type
var libraryType: Product.Library.LibraryType?
switch ProcessInfo.processInfo.environment["SCUI_LIBRARY_TYPE"] {
    case "static":
        libraryType = .static
    case "dynamic":
        libraryType = .dynamic
    case "auto":
        libraryType = nil
    case .some:
        print("Invalid SCUI_LIBRARY_TYPE, expected static, dynamic, or auto")
        libraryType = nil
    case nil:
        libraryType = hotReloadingEnabled ? .dynamic : nil
}

let package = Package(
    name: "swift-cross-ui",
    platforms: [
        .macOS(.v10_15),
        .iOS("7.0"),
        .tvOS(.v13),
        .macCatalyst(.v13)
    ],
    products: [
        .library(name: "SwiftCrossUI", type: libraryType, targets: ["SwiftCrossUI"]),
        .library(name: "AppKitBackend", type: libraryType, targets: ["AppKitBackend"]),
        .library(name: "GtkBackend", type: libraryType, targets: ["GtkBackend"]),
        .library(name: "Gtk3Backend", type: libraryType, targets: ["Gtk3Backend"]),
        .library(name: "DefaultBackend", type: libraryType, targets: ["DefaultBackend"]),
        .library(name: "UIKitBackend", type: libraryType, targets: ["UIKitBackend"]),
        .library(name: "Gtk", type: libraryType, targets: ["Gtk"]),
        .library(name: "Gtk3", type: libraryType, targets: ["Gtk3"]),
        .executable(name: "GtkExample", targets: ["GtkExample"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.0.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", exact: "1.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "0.0.0"),
        .package(url: "https://github.com/JWIMaster/UIKitCompatKit", branch: "master"),
    ],
    targets: [
        .target(
            name: "SwiftCrossUI",
            exclude: [
                "Builders/ViewBuilder.swift.gyb",
                "Builders/SceneBuilder.swift.gyb",
                "Builders/TableRowBuilder.swift.gyb",
                "Views/TupleView.swift.gyb",
                "Views/TupleViewChildren.swift.gyb",
                "Views/TableRowContent.swift.gyb",
                "Scenes/TupleScene.swift.gyb",
            ]
        ),
        .testTarget(
            name: "SwiftCrossUITests",
            dependencies: [
                "SwiftCrossUI",
                .target(name: "AppKitBackend", condition: .when(platforms: [.macOS])),
            ]
        ),
        .target(
            name: "DefaultBackend",
            dependencies: [
                .target(name: defaultBackend, condition: .when(platforms: [.linux, .macOS])),
                .target(name: "UIKitBackend", condition: .when(platforms: [.iOS, .tvOS, .macCatalyst])),
            ]
        ),
        .target(name: "AppKitBackend", dependencies: ["SwiftCrossUI"]),
        .target(name: "GtkBackend", dependencies: ["SwiftCrossUI", "Gtk", "CGtk"]),
        .target(name: "Gtk3Backend", dependencies: ["SwiftCrossUI", "Gtk3", "CGtk3"]),
        .systemLibrary(
            name: "CGtk",
            pkgConfig: "gtk4",
            providers: [
                .brew(["gtk4"]),
                .apt(["libgtk-4-dev clang"]),
            ]
        ),
        .target(name: "Gtk", dependencies: ["CGtk", "GtkCustomWidgets"], exclude: ["LICENSE.md"], swiftSettings: gtkSwiftSettings),
        .executableTarget(name: "GtkExample", dependencies: ["Gtk"], resources: [.copy("GTK.png")]),
        .target(name: "GtkCustomWidgets", dependencies: ["CGtk"]),
        .executableTarget(name: "GtkCodeGen", dependencies: ["XMLCoder"]),
        .systemLibrary(
            name: "CGtk3",
            pkgConfig: "gtk+-3.0",
            providers: [
                .brew(["gtk+3"]),
                .apt(["libgtk-3-dev clang"]),
            ]
        ),
        .target(name: "Gtk3", dependencies: ["CGtk3", "Gtk3CustomWidgets"], exclude: ["LICENSE.md"], swiftSettings: gtkSwiftSettings),
        .executableTarget(name: "Gtk3Example", dependencies: ["Gtk3"], resources: [.copy("GTK.png")]),
        .target(name: "Gtk3CustomWidgets", dependencies: ["CGtk3"]),
        .target(name: "UIKitBackend", dependencies: [
            "SwiftCrossUI",
            .product(name: "UIKitCompatKit", package: "UIKitCompatKit"),
        ]),
    ]
)

func getGtk4MinorVersion() -> Int? {
    #if os(Windows)
        return nil // Windows backend removed
    #else
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "gtk4-launch --version"]
        let pipe = Pipe()
        process.standardOutput = pipe

        guard (try? process.run()) != nil,
              let data = try? pipe.fileHandleForReading.readToEnd(),
              case _ = process.waitUntilExit(),
              let version = String(data: data, encoding: .utf8)?.split(separator: ".")
        else {
            print("Failed to get gtk version")
            return nil
        }
    #endif
    guard version.count >= 2, let minor = Int(version[1]) else {
        print("Failed to get gtk version")
        return nil
    }
    return minor
}
