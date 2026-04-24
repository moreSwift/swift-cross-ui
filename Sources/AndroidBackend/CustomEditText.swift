import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomEditText",
    extends: AndroidKit.EditText.self
)
class CustomEditText: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        activity: Activity?,
        onChange: SwiftAction? = nil,
        onSubmit: SwiftAction? = nil,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setOnChange(_ action: SwiftAction?)

    @JavaMethod
    func setOnSubmit(_ action: SwiftAction?)
}
