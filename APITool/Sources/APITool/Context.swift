import Foundation

/// General context required by all subcommands. Loads SCUI and SwiftUI, and
/// performs analysis.
struct Context {
    static let swiftUICoreInterfacePath = "Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-macos.swiftinterface"

    static let swiftUIInterfacePath = "Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface"

    static let swiftCrossUIInterfacePath = ".build/debug/SwiftCrossUI.build/SwiftCrossUI.swiftinterface"

    let swiftCrossUIAnalysis: Analyzer.Result
    let swiftUIAnalysis: Analyzer.Result
    let diff: Differ.Diff

    static func load(_ arguments: CommonArguments) throws -> Context {
        let swiftCrossUICheckout = arguments.swiftCrossUICheckout
            ?? URL.currentDirectory

        let xcodeApp: URL
        if let location = arguments.xcodeApp {
            xcodeApp = location
        } else {
            xcodeApp = URL(fileURLWithPath: "/Applications/Xcode.app")
            guard xcodeApp.exists() else {
                throw GeneralError(
                    """
                    Could not find Xcode at standard location (\(xcodeApp.path)). \
                    Please specify the location to a valid Xcode installation with \
                    the --xcode-app command line option
                    """
                )
            }
        }

        // Prepare a SwiftCrossUI swiftinterface
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "swift", "build",
            "--target", "SwiftCrossUI",
            "-Xswiftc", "-emit-module-interface"
        ]
        process.currentDirectoryPath = swiftCrossUICheckout.path
        do {
            try process.run()
        } catch {
            throw GeneralError(
                """
                Failed to build SwiftCrossUI swiftinterface: failed to launch \
                process: \(error.localizedDescription)
                """
            )
        }
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw GeneralError(
                """
                Failed to build SwiftCrossUI swiftinterface: non-zero exit \
                status '\(process.terminationStatus)'
                """
            )
        }

        // Load and analyze SwiftCrossUI swiftinterface
        let swiftCrossUI = try InterfaceLoader.loadInterface(
            swiftCrossUICheckout / swiftCrossUIInterfacePath,
            moduleName: "SwiftCrossUI"
        )
        let scuiResult = Analyzer.analyze(interfaces: [swiftCrossUI])

        // Load and analyze SwiftUI & SwiftUICore swiftinterfaces (as one)
        let swiftUICore = try InterfaceLoader.loadInterface(
            xcodeApp / swiftUICoreInterfacePath,
            moduleName: "SwiftUICore"
        )
        let swiftUI = try InterfaceLoader.loadInterface(
            xcodeApp / swiftUIInterfacePath,
            moduleName: "SwiftUI"
        )
        let swiftUIResult = Analyzer.analyze(interfaces: [swiftUICore, swiftUI])

        // Diff the two libraries
        let diff = Differ.diff(
            swiftCrossUIAnalysis: scuiResult,
            swiftUIAnalysis: swiftUIResult
        )

        return Context(
            swiftCrossUIAnalysis: scuiResult,
            swiftUIAnalysis: swiftUIResult,
            diff: diff
        )
    }
}
