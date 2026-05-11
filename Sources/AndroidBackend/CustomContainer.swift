import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomContainer",
    extends: AndroidKit.ViewGroup.self
)
class CustomContainer: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    // MARK: Methods from ViewGroup, for convenience to avoid '.as(...)' casting

    @JavaMethod
    func removeAllViews()

    @JavaMethod
    func addView(_ view: AndroidKit.View?, _ index: Int32)

    @JavaMethod
    func getChildAt(_ index: Int32) -> AndroidKit.View?

    @JavaMethod
    func removeViewAt(_ index: Int32)
}

extension CustomContainer {
    @JavaClass(
        "dev.swiftcrossui.androidbackend.CustomContainer$LayoutParams",
        extends: AndroidKit.ViewGroup.LayoutParams.self
    )
    class LayoutParams: JavaObject {
        @JavaMethod
        func getWidth() -> Int32

        @JavaMethod
        func setWidth(_ width: Int32)

        @JavaMethod
        func getHeight() -> Int32

        @JavaMethod
        func setHeight(_ height: Int32)

        @JavaMethod
        func getX() -> Int32

        @JavaMethod
        func setX(_ x: Int32)

        @JavaMethod
        func getY() -> Int32

        @JavaMethod
        func setY(_ y: Int32)
    }
}
