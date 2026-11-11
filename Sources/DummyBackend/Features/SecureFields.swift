@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.SecureFields {
    public func createSecureField() -> Widget {
        TextField(isSecure: true)
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        updateTextField(
            secureField,
            placeholder: placeholder,
            environment: environment,
            onChange: onChange,
            onSubmit: onSubmit
        )
    }

    public func setContent(ofSecureField secureField: Widget, to content: String) {
        setContent(ofTextField: secureField, to: content)
    }

    public func getContent(ofSecureField secureField: Widget) -> String {
        getContent(ofTextField: secureField)
    }
}
