import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomNumberPicker",
    extends: AndroidKit.NumberPicker.self
)
class CustomNumberPicker: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func update(_ onChange: SwiftAction?, _ options: [String], _ isEnabled: Bool)
    
    // Inheritied from NumberPicker; only present to avoid the extra as() call Swift-side.
    @JavaMethod
    func getValue() -> Int32
}
