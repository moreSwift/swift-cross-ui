import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomSpinner",
    extends: AndroidKit.Spinner.self
)
class CustomSpinner: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func update(_ onChange: SwiftAction?, _ options: [String], _ isEnabled: Bool)
    
    // Inheritied from Spinner; only present to avoid the extra as() call Swift-side.
    @JavaMethod
    func getSelectedItemPosition() -> Int32
    
    @JavaMethod
    func selectOption(_ selectedOption: Int32)
}
