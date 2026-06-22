import AndroidKit
import SwiftCrossUI
import SwiftJava

extension AndroidBackend: BackendFeatures.TextFields, BackendFeatures.SecureFields,
    BackendFeatures.TextEditors
{
    public func createTextField() -> Widget {
        CustomEditText(activity: Self.activity, environment: Self.env)
    }

    private func updateTextField(
        _ textField: CustomEditText,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: (() -> Void)?,
        isMultiline: Bool
    ) {
        textField.setHint(charSequence(from: placeholder))
        textField.setOnChange(
            SwiftAction(environment: Self.env) {
                // Don't take textField as a weak reference, because otherwise it
                // gets dropped immediately (it's not actually held anywhere; it's
                // just a wrapper around a Java class instance). This doesn't cause
                // a reference cycle because textField doesn't hold the SwiftAction,
                // (Java does).
                let content = textField.getText().toString()
                onChange(content)
            }
        )
        textField.setEnabled(environment.isEnabled)
        textField.setMaxLines(isMultiline ? .max : 1)

        let expectedInputType = environment.textContentType.toInputType(isMultiline: isMultiline)
        if textField.getInputType() != expectedInputType {
            textField.setInputType(expectedInputType)
        }

        if let onSubmit {
            textField.setOnSubmit(SwiftAction(environment: Self.env, action: onSubmit))
        } else {
            textField.setOnSubmit(nil)
        }
        getTextStyle(from: environment).apply(to: textField)
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        updateTextField(
            textField.as(CustomEditText.self)!,
            placeholder: placeholder,
            environment: environment,
            onChange: onChange,
            onSubmit: onSubmit,
            isMultiline: false
        )
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textField = textField.as(CustomEditText.self)!
        textField.setTextFromSwift(content)
    }

    public func getContent(ofTextField textField: Widget) -> String {
        let textField = textField.as(AndroidKit.TextView.self)!
        return textField.getText().toString()
    }

    public func createSecureField() -> Widget {
        SecureEditText(activity: Self.activity, environment: Self.env)
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
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

    public func createTextEditor() -> Widget {
        let editText = CustomEditText(activity: Self.activity, environment: Self.env)
        editText.setBackground(nil)
        editText.setPadding(0, 0, 0, 0)
        return editText
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        updateTextField(
            textEditor.as(CustomEditText.self)!,
            placeholder: "",
            environment: environment,
            onChange: onChange,
            onSubmit: nil,
            isMultiline: true
        )
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        setContent(ofTextField: textEditor, to: content)
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        getContent(ofTextField: textEditor)
    }
}

@JavaClass("android.text.InputType")
class InputType: JavaObject {
}

extension JavaClass where JavaClass_T == InputType {
    @JavaStaticField(isFinal: true)
    var TYPE_CLASS_NUMBER: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_CLASS_PHONE: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_CLASS_TEXT: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_NUMBER_FLAG_DECIMAL: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_NUMBER_FLAG_SIGNED: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_NUMBER_VARIATION_NORMAL: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_TEXT_FLAG_MULTI_LINE: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_TEXT_VARIATION_EMAIL_ADDRESS: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_TEXT_VARIATION_NORMAL: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_TEXT_VARIATION_PERSON_NAME: Int32

    @JavaStaticField(isFinal: true)
    var TYPE_TEXT_VARIATION_URI: Int32
}

// swiftlint:disable force_try
extension TextContentType {
    public func toInputType(isMultiline: Bool) -> Int32 {
        let inputType = try! JavaClass<InputType>()

        var type: Int32 = 0
        switch self {
            case .text:
                type |= inputType.TYPE_CLASS_TEXT
                type |= inputType.TYPE_TEXT_VARIATION_NORMAL
                if isMultiline {
                    type |= inputType.TYPE_TEXT_FLAG_MULTI_LINE
                }
            case .digits(_):
                type |= inputType.TYPE_CLASS_NUMBER
                type |= inputType.TYPE_NUMBER_VARIATION_NORMAL
            case .url:
                type |= inputType.TYPE_CLASS_TEXT
                type |= inputType.TYPE_TEXT_VARIATION_URI
                if isMultiline {
                    type |= inputType.TYPE_TEXT_FLAG_MULTI_LINE
                }
            case .phoneNumber:
                type |= inputType.TYPE_CLASS_PHONE
            case .name:
                type |= inputType.TYPE_CLASS_TEXT
                type |= inputType.TYPE_TEXT_VARIATION_PERSON_NAME
                if isMultiline {
                    type |= inputType.TYPE_TEXT_FLAG_MULTI_LINE
                }
            case .decimal(let signed):
                type |= inputType.TYPE_CLASS_NUMBER
                type |= inputType.TYPE_NUMBER_FLAG_DECIMAL
                type |= inputType.TYPE_NUMBER_VARIATION_NORMAL
                if signed {
                    type |= inputType.TYPE_NUMBER_FLAG_SIGNED
                }
            case .emailAddress:
                type |= inputType.TYPE_CLASS_TEXT
                type |= inputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
                if isMultiline {
                    type |= inputType.TYPE_TEXT_FLAG_MULTI_LINE
                }
        }
        return type
    }
}
