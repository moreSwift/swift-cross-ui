import SwiftJava

/// A Java class that allows us to pass Swift `() -> Void` closures to Java code.
@JavaClass("dev.swiftcrossui.androidbackend.SwiftAction")
open class SwiftAction: JavaObject {
    @JavaMethod
    @_nonoverride public convenience init(
        closureObject: SwiftObject?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    open func getClosureObject() -> SwiftObject?
}

@JavaImplementation("dev.swiftcrossui.androidbackend.SwiftAction")
extension SwiftAction {
    @JavaMethod
    public func callSwift() {
        guard let object = getClosureObject() else {
            log("Warning: SwiftAction wasn't holding a closure at all")
            return
        }

        let value = object.value()
        guard let action = value as? () -> Void else {
            log(
                "Warning: SwiftAction wasn't holding an action closure; got \(type(of: value))"
            )
            return
        }

        action()
    }
}

extension SwiftAction {
    convenience init(environment: JNIEnvironment? = nil, action: @escaping () -> Void) {
        let object = SwiftObject(action, environment: environment)
        self.init(closureObject: object, environment: environment)
    }
}
