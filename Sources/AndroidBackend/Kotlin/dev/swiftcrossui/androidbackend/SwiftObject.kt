package dev.swiftcrossui.androidbackend

// Taken from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/java/com/pureswift/swiftandroid/SwiftObject.kt#L3-L4
/// Swift object retained by JVM. We have to support both 32-bit and 64-bit
/// systems, so we store the pointers as longs.
class SwiftObject(val pointerValue: Long) {
    override fun toString(): String {
        return toStringSwift()
    }

    external fun toStringSwift(): String

    fun finalize() {
        finalizeSwift()
    }

    external fun finalizeSwift()
}
