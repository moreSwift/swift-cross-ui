import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.TextEditors {
    public func createTextEditor() -> Widget {
        let textEditor = NSObservableTextView()
        textEditor.drawsBackground = false
        textEditor.delegate = textEditor
        textEditor.allowsUndo = true
        textEditor.isRichText = false
        textEditor.textContainerInset = .zero
        textEditor.textContainer?.lineFragmentPadding = 0
        return textEditor
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditor = textEditor as! NSObservableTextView
        textEditor.onEdit = { textView in
            onChange(self.getContent(ofTextEditor: textView))
        }
        let resolvedFont = environment.resolvedFont
        if textEditor.font != Self.font(for: resolvedFont) {
            textEditor.font = Self.font(for: resolvedFont)
        }
        textEditor.appearance = environment.colorScheme.nsAppearance
        textEditor.isEditable = environment.isEnabled

        if #available(macOS 14, *) {
            textEditor.contentType =
                switch environment.textContentType {
                    case .url:
                        .URL
                    case .phoneNumber:
                        .telephoneNumber
                    case .name:
                        .name
                    case .emailAddress:
                        .emailAddress
                    case .text, .digits(_), .decimal(_):
                        nil
                }
        }
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        (textEditor as! NSObservableTextView).string = content
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        (textEditor as! NSObservableTextView).string
    }
}
