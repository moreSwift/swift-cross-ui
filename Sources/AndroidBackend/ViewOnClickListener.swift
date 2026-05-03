import AndroidKit

// Adapted from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/swift/MainActivity.swift
@JavaClass(
    "dev.swiftcrossui.androidbackend.ViewOnClickListener",
    extends: AndroidView.View.OnClickListener.self
)
class ViewOnClickListener: JavaObject {
    typealias Action = () -> ()
    
    @JavaMethod
    @_nonoverride convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)
    
    @JavaMethod
    func getAction() -> SwiftObject?
}

@JavaImplementation("dev.swiftcrossui.androidbackend.ViewOnClickListener")
extension ViewOnClickListener {
    @JavaMethod
    func onClick() {
        let action = getAction()!.value() as! Action
        action()
    }
}

extension ViewOnClickListener {
    convenience init(action: @escaping () -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }
}
