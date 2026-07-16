import SwiftCrossUI
import DefaultBackend

@main
struct FontsApp: App {
    @State var isEmphasized = false
    @State var isMonospaced = false
    @State var isItalics = false
    @State var textCase: Text.Case? = nil

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
                Picker(of: [Text.Case.uppercase, .lowercase], selection: $textCase)

                ForEach(fonts, id: \.self) { font in
                    Text("The quick brown fox jumps over the lazy dog.")
                        .font(
                            font
                                .emphasized(isEmphasized)
                                .monospaced(isMonospaced)
                                .italic(isItalics)
                        )
                        .textCase(textCase)
                }
            }
            .toggleStyle(.checkbox)
        }
    }
}
