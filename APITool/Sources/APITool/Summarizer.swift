import MacroToolkit

enum Summarizer {
    struct Summary: CustomStringConvertible {
        struct DiffComponentSummary {
            var swiftCrossUI: Int
            var swiftUI: Int
            var shared: Int
            var missing: [String]
        }

        var summaries: [(String, DiffComponentSummary)] = []

        init() {}

        mutating func add<T: Comparable & Hashable & CustomStringConvertible>(
            _ name: String,
            _ component: Differ.Diff.Component<T>
        ) {
            let summary = DiffComponentSummary(
                swiftCrossUI: component.swiftCrossUI.count,
                swiftUI: component.swiftUI.count,
                shared: component.shared.count,
                missing: component.missing.map(\.description)
            )
            summaries.append((name, summary))
        }

        func renderSection<T: CustomStringConvertible>(
            _ name: String,
            prefix: String,
            value: (DiffComponentSummary) -> T
        ) -> String {
            var lines = ["== \(name) =="]
            let prefix = prefix.isEmpty ? "" : prefix + " "
            lines += summaries.map { name, summary in
                let name = prefix.isEmpty ? name.initialUppercased : name
                return "\(prefix)\(name): \(value(summary).description)"
            }
            return lines.joined(separator: "\n")
        }

        var description: String {
            [
                renderSection("Diff", prefix: "Missing", value: \.missing),
                renderSection("SwiftCrossUI", prefix: "#", value: \.swiftCrossUI),
                renderSection("SwiftUI", prefix: "#", value: \.swiftUI),
                renderSection("Feature parity", prefix: "") { summary in
                    Self.percentage(summary.shared, summary.swiftUI)
                },
            ].joined(separator: "\n\n")
        }

        static func percentage(_ count: Int, _ total: Int) -> String {
            let fraction = Double(count) / Double(total)
            let percent = String(format: "%.01f%%", fraction * 100)
            return "\(percent) (\(count)/\(total))"
        }
    }

    static func summarize(diff: Differ.Diff) -> Summary {
        var summary = Summary()
        summary.add("views", diff.views)
        summary.add("view modifiers (by signature)", diff.viewModifiers)
        summary.add("view modifiers (by name)", diff.uniqueViewModifiers)
        summary.add("enums", diff.enums)
        summary.add("non-view structs", diff.nonViewStructs)
        return summary
    }
}
