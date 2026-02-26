import JavaKit

// Adapted from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/swift/JavaRetainedValue.swift#L13
/// Java class that retains a Swift value for the duration of its lifetime.
@JavaClass("dev.swiftcrossui.androidbackend.SwiftObject")
open class SwiftObject: JavaObject {
    @JavaMethod
    @_nonoverride public convenience init(swiftObject: Int64, type: String, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getSwiftObject() -> Int64

    @JavaMethod
    open func getType() -> String
}

@JavaImplementation("dev.swiftcrossui.androidbackend.SwiftObject")
extension SwiftObject {
    @JavaMethod
    public func toStringSwift() -> String {
        "[a Swift object]"
    }

    @JavaMethod
    public func finalizeSwift() {
        // release owned swift value
        release()
    }
}

extension SwiftObject {
    convenience init<T>(_ value: T, environment: JNIEnvironment? = nil) {
        let box = JavaRetainedValue(value)
        let type = box.type
        self.init(swiftObject: box.id, type: type, environment: environment)
        // retain value
        retain(box)
    }

    @MainActor
    func valueObject() -> JavaRetainedValue {
        let id = getSwiftObject()
        guard let object = Self.retained[id] else {
            fatalError()
        }
        return object
    }
}

private extension SwiftObject {
    @MainActor
    static var retained = [JavaRetainedValue.ID: JavaRetainedValue]()

    func retain(_ value: JavaRetainedValue) {
        Task { @MainActor in
            Self.retained[value.id] = value
        }
    }

    func release() {
        let id = getSwiftObject()
        Task { @MainActor in
            Self.retained[id] = nil
        }
    }
}

/// Swift Object retained until released by Java object.
final class JavaRetainedValue: Identifiable, @unchecked Sendable {
    let value: Any

    var type: String {
        String(describing: Swift.type(of: value))
    }

    var id: Int64 {
        Int64(ObjectIdentifier(self).hashValue)
    }

    init<T>(_ value: T) {
        self.value = value
    }
}
