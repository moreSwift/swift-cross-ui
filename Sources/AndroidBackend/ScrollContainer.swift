import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.ScrollContainer",
    extends: AndroidKit.FrameLayout.self
)
class ScrollContainer: AndroidKit.FrameLayout {
    @JavaMethod
    convenience init(
        activity: AndroidKit.Activity!,
        child: AndroidKit.View!,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func updateScroll(vertical: Bool, horizontal: Bool)
}
