import AndroidKit
import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.CustomSheet")
public class CustomSheet: JavaObject {
    @JavaMethod
    convenience init(_ content: AndroidKit.View?, environment: JNIEnvironment? = nil)

    @JavaMethod
    func getContent() -> AndroidKit.View?

    @JavaMethod
    func setOnDismissListener(_ onDismissListener: SwiftAction?)

    @JavaMethod
    func update(_ isDismissable: Bool, _ backgroundColor: Int32)

    // Inherited from BottomSheetDialogFragment
    @JavaMethod
    func dismiss()

    // Inherited from DialogFragment
    @JavaMethod
    func show(_ fragmentManager: AndroidxFragmentManager?, _ tag: String)

    // Inherited from Fragment
    @JavaMethod
    func getChildFragmentManager() -> AndroidxFragmentManager?
}
