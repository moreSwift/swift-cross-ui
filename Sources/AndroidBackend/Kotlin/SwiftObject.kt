package dev.swiftcrossui.androidbackend

/// Swift object retained by JVM. We have to support both 32-bit and 64-bit
/// systems, so we store the pointers as longs.
class SwiftObject(val pointerValue: Long) {
    override fun toString(): String {
        return toStringSwift()
    }

    external fun toStringSwift(): String

    protected fun finalize() {
        finalizeSwift()
    }

    external fun finalizeSwift()
}
