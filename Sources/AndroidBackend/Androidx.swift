import AndroidKit
import SwiftJava

@JavaClass("androidx.fragment.app.FragmentManager")
class AndroidxFragmentManager: JavaObject {}

@JavaClass(
    "androidx.fragment.app.FragmentActivity",
    extends: AndroidKit.Activity.self
)
open class FragmentActivity: AndroidKit.Activity {
    @JavaMethod
    func getSupportFragmentManager() -> AndroidxFragmentManager?
}

@JavaClass(
    "androidx.fragment.app.Fragment",
    implements: AndroidKit.ComponentCallbacks.self,
    AndroidKit.View.OnCreateContextMenuListener.self
)
open class AndroidxFragment: JavaObject {
    @JavaMethod
    open func getView() -> AndroidKit.View?
}
