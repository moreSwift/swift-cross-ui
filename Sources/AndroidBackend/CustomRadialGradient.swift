import SwiftJava
import AndroidKit

// This class exists to circumvent the weird issue of the AndroidGraphics bindings
// we use not finding the class android.graphics.RadialGradient.
// On the Kotlin side of things CustomRadialGradient is just a subclass of
// RadialGradient, without any additional logic.
@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomRadialGradient",
    extends: AndroidKit.RadialGradient.self
)
class CustomRadialGradient: AndroidKit.RadialGradient {
    @JavaMethod
    @_nonoverride convenience init(
        _ centerX: Float,
        _ centerY: Float,
        _ radius: Float,
        _ colors: [Int32],
        _ stops: [Float],
        _ tileMode: Shader.TileMode?,
        environment: JNIEnvironment? = nil
    )
}
