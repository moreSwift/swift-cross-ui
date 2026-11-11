import SwiftJava
import AndroidKit
import AndroidGraphics

@JavaClass(
    "dev.swiftcrossui.androidbackend.PathView",
    extends: AndroidKit.View.self
)
class PathView: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func set(
        path: AndroidGraphics.Path?,
        fillPaint: AndroidKit.Paint?,
        strokePaint: AndroidKit.Paint?
    )
}
