// import AndroidKit

// @JavaClass(
//     "dev.swiftcrossui.androidbackend.SwiftTextWatcher",
//     extends: AndroidKit.TextWatcher.self
// )
// class SwiftTextWatcher: JavaObject {
//     typealias Action = () -> ()
    
//     @JavaMethod
//     @_nonoverride convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)
    
//     @JavaMethod
//     func getAction() -> SwiftObject?
// }

// @JavaImplementation("dev.swiftcrossui.androidbackend.SwiftTextWatcher")
// extension SwiftTextWatcher {
//     @JavaMethod
//     func afterTextChanged(editable: Editable) {
//         let action = getAction()!.value() as! Action
//         action()
//     }
// }

// extension SwiftTextWatcher {
//     convenience init(action: @escaping () -> (), environment: JNIEnvironment? = nil) {
//         let object = SwiftObject(action, environment: environment)
//         self.init(action: object, environment: environment)
//     }
// }
