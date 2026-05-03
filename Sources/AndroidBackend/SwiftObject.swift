import SwiftJava

// Adapted from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/swift/JavaRetainedValue.swift#L13
/// Java class that retains a Swift value for the duration of its lifetime.
@JavaClass("dev.swiftcrossui.androidbackend.SwiftObject")
open class SwiftObject: JavaObject {
    @JavaMethod
    @_nonoverride public convenience init(
        pointerValue: Int64,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    open func getPointerValue() -> Int64
}

@JavaImplementation("dev.swiftcrossui.androidbackend.SwiftObject")
extension SwiftObject {
    @JavaMethod
    public func toStringSwift() -> String {
        "\(value())"
    }

    @JavaMethod
    public func finalizeSwift() {
        Box.finalize(pointerValue: getPointerValue())
    }
}

extension SwiftObject {
    convenience init<T>(_ value: T, environment: JNIEnvironment? = nil) {
        let box = Box(value)
        self.init(pointerValue: box.pointerValue, environment: environment)
    }

    func value() -> Any {
        let pointerValue = getPointerValue()
        let box = Box.from(pointerValue: pointerValue)
        return box.value
    }
}

/// Swift Object retained until released by Java object.
final class Box: Identifiable {
    let value: Any

    init<T>(_ value: T) {
        self.value = value
    }

    static func from(pointerValue: Int64) -> Box {
        let pointerValue = Int(pointerValue)
        let pointer = UnsafeRawPointer(bitPattern: pointerValue)!
        let box = Unmanaged<Box>.fromOpaque(pointer)
            .takeUnretainedValue()
        return box
    }

    static func finalize(pointerValue: Int64) {
        let pointerValue = Int(pointerValue)
        let pointer = UnsafeRawPointer(bitPattern: pointerValue)!
        Unmanaged<Box>.fromOpaque(pointer).release()
    }

    var pointerValue: Int64 {
        let pointer = Unmanaged<Box>.passRetained(self)
        return Int64(Int(bitPattern: pointer.toOpaque()))
    }
}
