import SwiftCrossUI
import DefaultBackend

@main
struct FontsApp: App {
    @State var isEmphasized = false
    @State var isMonospaced = false
    @State var isItalics = false
    @State var textCase: OptionalTextCase? = .unset

    let fonts: [Font] = [
        .largeTitle,
        .title,
        .title2,
        .title3,
        .headline,
        .subheadline,
        .body,
        .callout,
        .caption,
        .caption2,
        .footnote
    ]

    var body: some Scene {
        WindowGroup("FontsApp") {
            VStack {
                Toggle("Emphasize text", isOn: $isEmphasized)
                Toggle("Monospaced text", isOn: $isMonospaced)
                Toggle("Italics", isOn: $isItalics)
                HStack {
                    Text("Text case:")
                    Picker(of: OptionalTextCase.allCases, selection: $textCase)
                }

                ForEach(fonts, id: \.self) { font in
                    Text("The quick brown fox jumps over the lazy dog.")
                        .font(
                            font
                                .emphasized(isEmphasized)
                                .monospaced(isMonospaced)
                                .italic(isItalics)
                        )
                        .textCase(textCase?.textCase)
                }
            }
            .toggleStyle(.checkbox)
        }
    }
}

// TODO(kaleb): Remove this hacky enum once we can apply arbitrary labels to picker options.
enum OptionalTextCase: CaseIterable, CustomStringConvertible {
    case uppercase
    case lowercase
    case unset

    var textCase: Text.Case? {
        switch self {
            case .uppercase: .uppercase
            case .lowercase: .lowercase
            case .unset: nil
        }
    }

    var description: String {
        switch self {
            case .uppercase: "Uppercase"
            case .lowercase: "Lowercase"
            case .unset: "Unset"
        }
    }
}
