import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.AlertFragment",
    extends: AndroidKit.DialogFragment.self
)
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

    @JavaMethod
    func show(_ activity: AndroidKit.Activity?)
    
    // Inherited from DialogFragment
    @JavaMethod
    func dismiss()
}
