import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomEditText",
    extends: AndroidKit.EditText.self
)
class CustomEditText: AndroidKit.EditText {
    @JavaMethod
    @_nonoverride convenience init(
        activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setOnChange(_ action: SwiftAction?)

    @JavaMethod
    func setOnSubmit(_ action: SwiftAction?)

    @JavaMethod
    func setTextFromSwift(_ text: String)
}

@JavaClass("dev.swiftcrossui.androidbackend.SecureEditText", extends: CustomEditText.self)
class SecureEditText: CustomEditText {
    @JavaMethod
    @_nonoverride convenience init(
        activity: Activity?,
        environment: JNIEnvironment? = nil
    )
}
