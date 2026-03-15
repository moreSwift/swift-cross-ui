import CWinRT
import Foundation
import SwiftCrossUI
import UWP
import WinAppSDK
import WinSDK
import WinUI
import WinUIInterop
import WindowsFoundation

// Many force tries are required for the WinUI backend but we don't really want them
// anywhere else so just disable the lint rule at a file level.
// swiftlint:disable force_try

extension WinUIBackend {
    public func createTextField(secure: Bool) -> Widget {
        let textField: TextBoxProtocol = if secure { PasswordBox() } else { TextBox() }

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
        let textField = textField as! TextBoxProtocol
        textField.placeholderText = placeholder
        internalState.textFieldChangeActions[ObjectIdentifier(textField)] = onChange
        internalState.textFieldSubmitActions[ObjectIdentifier(textField)] = onSubmit
        environment.apply(to: textField)

        updateInputScope(of: textField, textContentType: environment.textContentType)
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textField = textField as! TextBoxProtocol
        textField.text = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        (textField as! TextBoxProtocol).text
    }
}

// `TextBox` and `PasswordBox` are two separate classes implemented on top of
// `Control`, and both implement all the textbox-y things independently. So we
// need a wrapper protocol in order to use them as if they're the same type.

protocol TextBoxProtocol: Control {
    func addTextChangedHandler(_ handler: (String) -> Void)
    var text: String { get set }
    var placeholderText: String { get set }
    var inputScope: InputScope! { get set }
}

extension TextBox: TextBoxProtocol {
    func addTextChangedHandler(_ handler: @escaping (String) -> Void) {
        textChanged.addHandler { _, _ in
            handler()
        }
    }
}

extension PasswordBox: TextBoxProtocol {
    func addTextChangedHandler(_ handler: @escaping (String) -> Void) {
        passwordChanged.addHandler { _, _ in
            handler()
        }
    }
    var text: String {
        get { password }
        set { password = newValue }
    }
}
