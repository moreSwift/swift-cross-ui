import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomRadioGroup",
    extends: AndroidKit.RadioGroup.self
)
class CustomRadioGroup: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func update(
        _ onChange: SwiftAction?,
        _ options: [String],
        _ isEnabled: Bool,
        color: Int32,
        fontSize: Float,
        lineHeight: Int32,
        _ typeface: AndroidKit.Typeface?
    )

    @JavaMethod
    func getSelectedOption() -> Int32

    @JavaMethod
    func selectOption(_ index: Int32)
}
