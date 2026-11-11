import ArgumentParser
import Foundation

struct AnalyzeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "analyze"
    )

    @OptionGroup
    var common: CommonArguments

    func run() {
        do {
            let context = try Context.load(common)
            let summary = Summarizer.summarize(diff: context.diff)
            print(summary)
        } catch {
            print("Error: \(error.localizedDescription)")
            Foundation.exit(1)
        }
    }
}
