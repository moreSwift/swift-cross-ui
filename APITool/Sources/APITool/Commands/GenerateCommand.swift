import ArgumentParser
import Foundation

struct GenerateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate"
    )

    @OptionGroup
    var common: CommonArguments

    @Argument
    var outputDirectory: String

    func run() {
        do {
            // Prepare output directory
            let outputDirectory = URL(fileURLWithPath: outputDirectory)
            if outputDirectory.exists() {
                try FileManager.default.removeItem(at: outputDirectory)
            }
            try FileManager.default.createDirectory(
                at: outputDirectory,
                // It's a little more likely for us to catch typos if we don't
                // automatically create intermediate directories.
                withIntermediateDirectories: false
            )

            // Analyze SCUI and generate stubs
            let context = try Context.load(common)
            try StubGenerator.generateStub(
                context: context,
                outputDirectory: outputDirectory
            )

            print("Done")
        } catch {
            print("Error: \(error.localizedDescription)")
            Foundation.exit(1)
        }
    }
}
