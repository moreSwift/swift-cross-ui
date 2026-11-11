import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.SecureFields {
    public func createSecureField() -> Widget {
        // Using the `(string:)` initializer ensures that the SecureField scrolls
        // smoothly on horizontal overflow instead of jumping a full width at a
        // time.
        let textField = NSObservableSecureTextField(string: "")
        textField.cell?.sendsActionOnEndEditing = false
        return textField
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let secureField = secureField as! NSObservableSecureTextField
        secureField.isEnabled = environment.isEnabled
        secureField.placeholderString = placeholder
        secureField.appearance = environment.colorScheme.nsAppearance
        let resolvedFont = environment.resolvedFont
        if secureField.font != Self.font(for: resolvedFont) {
            secureField.font = Self.font(for: resolvedFont)
        }

        secureField.onEdit = { _ in
            onChange(secureField.stringValue)
        }
        secureField.onSubmit = onSubmit

        if #available(macOS 14, *) {
            secureField.contentType =
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

    public func setContent(ofSecureField secureField: Widget, to content: String) {
        let secureField = secureField as! NSTextField
        secureField.stringValue = content
    }

    public func getContent(ofSecureField secureField: Widget) -> String {
        let secureField = secureField as! NSTextField
        return secureField.stringValue
    }
}
