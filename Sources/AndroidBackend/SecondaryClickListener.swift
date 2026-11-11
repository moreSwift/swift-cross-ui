import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.SecondaryClickListener",
    implements: AndroidKit.View.OnTouchListener.self
)
class SecondaryClickListener: JavaObject {
    @JavaMethod
    convenience init(_ action: SwiftAction?, environment: JNIEnvironment? = nil)
}

extension SecondaryClickListener {
    convenience init(action: @escaping () -> Void, environment: JNIEnvironment?) {
        let swiftAction = SwiftAction(environment: environment, action: action)
        self.init(swiftAction, environment: environment)
    }
}
