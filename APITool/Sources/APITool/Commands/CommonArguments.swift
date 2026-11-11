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
        name: .customLong("developer-dir"),
        help: """
            The location of your Xcode or CLT developer dir. The default \
            behavior is to fetch the active developer dir using \
            'xcode-select --print-path'
            """,
        transform: { (path: String) in
            URL(fileURLWithPath: path)
        }
    )
    var developerDirectory: URL?
}
