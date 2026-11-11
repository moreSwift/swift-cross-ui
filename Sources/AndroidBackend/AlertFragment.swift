import SwiftJava
import AndroidKit

@JavaClass("dev.swiftcrossui.androidbackend.AlertFragment")
public class AlertFragment: JavaObject {
    @JavaMethod
    func getButtonIndex() -> Int32

    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func update(
        _ title: String,
        _ buttons: [String]
    )

    // Inherited from DialogFragment
    @JavaMethod
    func show(_ manager: AndroidxFragmentManager?, _ tag: String)

    // Inherited from DialogFragment
    @JavaMethod
    func dismiss()
}
