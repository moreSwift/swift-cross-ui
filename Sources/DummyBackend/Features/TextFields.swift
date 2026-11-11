@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.TextFields {
    public func createTextField() -> Widget {
        TextField(isSecure: false)
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! TextField
        textField.placeholder = placeholder
        textField.font = environment.resolvedFont
        textField.changeHandler = onChange
        textField.submitHandler = onSubmit
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        (textField as! TextField).value = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        (textField as! TextField).value
    }
}
