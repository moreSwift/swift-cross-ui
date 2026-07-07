import AndroidKit
import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.CustomSlider")
class CustomSlider: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: AndroidKit.Activity!,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func setBounds(min: Float, max: Float, places: Int32)

    // Inherited from Slider
    @JavaMethod
    func getValue() -> Float

    @JavaMethod
    func setValue(_ value: Float)

    // Inherited from BaseSlider
    @JavaMethod
    func setEnabled(_ enabled: Bool)
}
