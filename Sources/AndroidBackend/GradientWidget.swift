import SwiftJava
import AndroidKit
import AndroidGraphics

@JavaClass(
    "dev.swiftcrossui.androidbackend.GradientWidget",
    extends: AndroidKit.View.self
)
class GradientWidget: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )
    
    @JavaMethod
    func set(
        shader: AndroidGraphics.Shader?,
        width: Float,
        height: Float
    )
    
    /// Applies a transformation matrix to the currently used Shader.
    /// Only call this method AFTER set, to ensure the shader is set.
    @JavaMethod
    func setMatrix(
        centerX: Float,
        centerY: Float,
        rotationAngle: Float,
        scaleX: Float,
        scaleY: Float
    )
}
