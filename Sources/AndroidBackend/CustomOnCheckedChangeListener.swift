import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomOnCheckedChangeListener",
    implements: AndroidKit.CompoundButton.OnCheckedChangeListener.self
)
class CustomOnCheckedChangeListener: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ action: SwiftAction?,
        environment: JNIEnvironment? = nil
    )
}
