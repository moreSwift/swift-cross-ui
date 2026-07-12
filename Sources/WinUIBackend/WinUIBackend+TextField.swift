@_spi(Backends) import SwiftCrossUI
import WinUI

// Many force tries are required for the WinUI backend but we don't really want them
// anywhere else so just disable the lint rule at a file level.
// swiftlint:disable force_try

// MARK: TextField

extension WinUIBackend {
    public func createTextField() -> Widget {
        let textField = TextBox()
        textField.textChanged.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            let identifier = ObjectIdentifier(textField)
            let text = textField.text
            guard internalState.textFieldContents[identifier] != text else {
                return
            }
            internalState.textFieldContents[identifier] = text
            internalState.textFieldChangeActions[identifier]?(text)
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
        let textField = textField as! TextBox
        let identifier = ObjectIdentifier(textField)
        internalState.textFieldContents[identifier] = content
        guard textField.text != content else {
            return
        }
        textField.text = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        (textField as! TextBox).text
    }
}

// MARK: SecureField

extension WinUIBackend {
    public func createSecureField() -> Widget {
        let secureField = PasswordBox()
        secureField.passwordChanged.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            let identifier = ObjectIdentifier(secureField)
            let password = secureField.password
            guard internalState.textFieldContents[identifier] != password else {
                return
            }
            internalState.textFieldContents[identifier] = password
            internalState.textFieldChangeActions[identifier]?(password)
        }
        secureField.keyUp.addHandler { [weak internalState] _, event in
            guard let internalState else { return }

            if event?.key == .enter {
                internalState.textFieldSubmitActions[ObjectIdentifier(secureField)]?()
            }
        }
        return secureField
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let secureField = secureField as! PasswordBox
        secureField.placeholderText = placeholder
        internalState.textFieldChangeActions[ObjectIdentifier(secureField)] = onChange
        internalState.textFieldSubmitActions[ObjectIdentifier(secureField)] = onSubmit
        environment.apply(to: secureField)

        updateInputScope(of: secureField, textContentType: environment.textContentType)
    }

    public func setContent(ofSecureField secureField: Widget, to content: String) {
        let secureField = secureField as! PasswordBox
        let identifier = ObjectIdentifier(secureField)
        internalState.textFieldContents[identifier] = content
        guard secureField.password != content else {
            return
        }
        secureField.password = content
    }

    public func getContent(ofSecureField secureField: Widget) -> String {
        (secureField as! PasswordBox).password
    }
}

// MARK: TextBoxProtocol

protocol TextBoxProtocol: Control {
    var inputScope: InputScope! { get set }
}

extension TextBox: TextBoxProtocol {}
extension PasswordBox: TextBoxProtocol {}
