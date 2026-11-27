@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.SecureFields {
    public func createSecureField() -> Widget {
        let secureField = PasswordBox()
        secureField.passwordChanged.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            internalState.textFieldChangeActions[ObjectIdentifier(secureField)]?(
                secureField.password
            )
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
        (secureField as! PasswordBox).password = content
    }

    public func getContent(ofSecureField secureField: Widget) -> String {
        (secureField as! PasswordBox).password
    }
}

extension PasswordBox: TextBoxProtocol {}
