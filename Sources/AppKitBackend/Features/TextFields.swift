import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.TextFields {
    public func createTextField() -> Widget {
        // Using the `(string:)` initializer ensures that the TextField scrolls
        // smoothly on horizontal overflow instead of jumping a full width at a
        // time.
        let textField = NSObservableTextField(string: "")
        textField.cell?.sendsActionOnEndEditing = false
        return textField
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! NSObservableTextField
        textField.isEnabled = environment.isEnabled
        textField.placeholderString = placeholder
        textField.appearance = environment.colorScheme.nsAppearance
        let resolvedFont = environment.resolvedFont
        if textField.font != Self.font(for: resolvedFont) {
            textField.font = Self.font(for: resolvedFont)
        }

        textField.onEdit = { textField in
            onChange(textField.stringValue)
        }
        textField.onSubmit = onSubmit

        if #available(macOS 14, *) {
            textField.contentType =
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

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textField = textField as! NSTextField
        textField.stringValue = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        let textField = textField as! NSTextField
        return textField.stringValue
    }
}
