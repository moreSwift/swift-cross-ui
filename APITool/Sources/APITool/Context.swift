import Foundation

/// General context required by all subcommands. Loads SCUI and SwiftUI, and
/// performs analysis.
struct Context {
    static let swiftUICoreInterfacePath = "MacOSX.sdk/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64e-apple-macos.swiftinterface"

    static let swiftUIInterfacePath = "MacOSX.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface"

    static let swiftCrossUIInterfacePath = ".build/debug/SwiftCrossUI.build/SwiftCrossUI.swiftinterface"

    let swiftCrossUIAnalysis: Analyzer.Result
    let swiftUIAnalysis: Analyzer.Result
    let diff: Differ.Diff

    static func load(_ arguments: CommonArguments) throws -> Context {
        let swiftCrossUICheckout = arguments.swiftCrossUICheckout
            ?? URL.currentDirectory

        let developerDirectory: URL
        if let location = arguments.developerDirectory {
            developerDirectory = location
        } else {
            do {
                developerDirectory = try getDefaultDeveloperDirectory()
            } catch {
                throw GeneralError(
                    """
                    Failed to get default developer directory using \
                    'xcode-select --print-path'. Please provide the path to \
                    your active developer directory manually using \
                    '--developer-dir'. Cause: \(error.localizedDescription)
                    """
                )
            }
        }

        // If the developer directory points to a CommandLineTools installation
        // then the SDKs that we require are at a different location.
        let sdksDirectory: URL
        let cltSDKsDirectory = developerDirectory / "SDKs"
        if cltSDKsDirectory.exists() {
            sdksDirectory = cltSDKsDirectory
        } else {
            sdksDirectory = developerDirectory / "Platforms/MacOSX.platform/Developer/SDKs"
        }

        // Build SwiftCrossUI to prepare the required swiftinterface file
        let scuiInterfaceFile = try prepareSwiftCrossUISwiftInterface(
            checkout: swiftCrossUICheckout
        )

        // Load and analyze SwiftCrossUI swiftinterface
        let swiftCrossUI = try InterfaceLoader.loadInterface(
            scuiInterfaceFile,
            moduleName: "SwiftCrossUI"
        )
        let scuiResult = Analyzer.analyze(interfaces: [swiftCrossUI])

        // Load and analyze SwiftUI & SwiftUICore swiftinterfaces (as one)
        let swiftUICore = try InterfaceLoader.loadInterface(
            sdksDirectory / swiftUICoreInterfacePath,
            moduleName: "SwiftUICore"
        )
        let swiftUI = try InterfaceLoader.loadInterface(
            sdksDirectory / swiftUIInterfacePath,
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

    /// Builds SwiftCrossUI with special arguments to produce the
    /// swiftinterface file that we need for our analyses.
    private static func prepareSwiftCrossUISwiftInterface(
        checkout swiftCrossUICheckout: URL
    ) throws -> URL {
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

        return swiftCrossUICheckout / swiftCrossUIInterfacePath
    }

    /// Gets the user's default developer directory by running
    /// 'xcode-select --print-path'.
    private static func getDefaultDeveloperDirectory() throws -> URL {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            "xcode-select", "--print-path"
        ]
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw GeneralError("non-zero exit status")
        }
        let pathData = pipe.fileHandleForReading.availableData
        guard let path = String(data: pathData, encoding: .utf8) else {
            throw GeneralError("process produced non-utf8 output")
        }
        let cleanedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(fileURLWithPath: cleanedPath)
    }
}
