import ArgumentParser
import Foundation

struct CommonArguments: ParsableArguments {
    @Option(
        name: .customLong("scui-checkout"),
        help: """
            The location of the SwiftCrossUI checkout to operate on. Defaults \
            to the current directory
            """,
        transform: { (path: String) in
            URL(fileURLWithPath: path)
        }
    )
    var swiftCrossUICheckout: URL?

    @Option(
        name: .customLong("xcode-app"),
        help: "The location of Xcode.app. Defaults to /Applications/Xcode.app",
        transform: { (path: String) in
            URL(fileURLWithPath: path)
        }
    )
    var xcodeApp: URL?
}
