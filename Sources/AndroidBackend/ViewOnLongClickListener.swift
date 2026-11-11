import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.ViewOnLongClickListener",
    implements: AndroidView.View.OnLongClickListener.self
)
class ViewOnLongClickListener: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(action: SwiftAction?, environment: JNIEnvironment? = nil)
}

extension ViewOnLongClickListener {
    convenience init(action: @escaping () -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftAction(environment: environment, action: action)
        self.init(action: object, environment: environment)
    }
}
