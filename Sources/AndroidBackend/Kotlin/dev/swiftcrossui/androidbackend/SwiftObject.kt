package dev.swiftcrossui.androidbackend

// Taken from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/java/com/pureswift/swiftandroid/SwiftObject.kt#L3-L4
/// Swift object retained by JVM
class SwiftObject(val swiftObject: Long, val type: String) {
    override fun toString(): String {
        return toStringSwift()
    }

    external fun toStringSwift(): String

    fun finalize() {
        finalizeSwift()
    }

    external fun finalizeSwift()
}
