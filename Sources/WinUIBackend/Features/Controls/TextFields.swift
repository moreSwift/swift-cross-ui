@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.TextFields {
    public func createTextField() -> Widget {
        let textField = TextBox()
        textField.textChanged.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            internalState.textFieldChangeActions[ObjectIdentifier(textField)]?(textField.text)
        }
        textField.keyUp.addHandler { [weak internalState] _, event in
            guard let internalState else { return }

            if event?.key == .enter {
                internalState.textFieldSubmitActions[ObjectIdentifier(textField)]?()
            }
        }
        return textField
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! TextBox
        textField.placeholderText = placeholder
        internalState.textFieldChangeActions[ObjectIdentifier(textField)] = onChange
        internalState.textFieldSubmitActions[ObjectIdentifier(textField)] = onSubmit
        environment.apply(to: textField)

        updateInputScope(of: textField, textContentType: environment.textContentType)
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        (textField as! TextBox).text = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        (textField as! TextBox).text
    }
}

protocol TextBoxProtocol: Control {
    var inputScope: InputScope! { get set }
}

extension TextBox: TextBoxProtocol {}
