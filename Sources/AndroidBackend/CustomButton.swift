import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomButton",
    extends: AndroidKit.FrameLayout.self
)
class CustomButton: AndroidKit.FrameLayout {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func set(action: SwiftAction?, buttonStyle: Int16, isEnabled: Bool, isDarkMode: Bool)
}

extension JavaClass where JavaClass_T == CustomButton {
    @JavaStaticField(isFinal: true)
    var horizontalPadding: Int32

    @JavaStaticField(isFinal: true)
    var verticalPadding: Int32

    @JavaStaticField(isFinal: true)
    var borderedButtonStyle: Int16

    @JavaStaticField(isFinal: true)
    var plainButtonStyle: Int16

    @JavaStaticField(isFinal: true)
    var borderlessButtonStyle: Int16
}
