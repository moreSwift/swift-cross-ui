import ArgumentParser
import Foundation

@main
struct APITool: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "APITool",
        subcommands: [
            AnalyzeCommand.self,
            GenerateCommand.self,
        ]
    )
}
