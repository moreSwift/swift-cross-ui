import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.ViewOnClickListener",
    extends: AndroidView.View.OnClickListener.self
)
class ViewOnClickListener: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(action: SwiftAction?, environment: JNIEnvironment? = nil)
}

extension ViewOnClickListener {
    convenience init(action: @escaping () -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftAction(environment: environment, action: action)
        self.init(action: object, environment: environment)
    }
}
