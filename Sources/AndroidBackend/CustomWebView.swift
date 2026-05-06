import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomWebView",
    extends: AndroidKit.WebView.self
)
class CustomWebView: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setOnNavigate(_ action: SwiftAction?)

    @JavaMethod
    func loadUrl(_ url: String)
    
    @JavaMethod
    func getLoadingUrl() -> JavaString?
}
