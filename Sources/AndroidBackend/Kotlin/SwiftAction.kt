package dev.swiftcrossui.androidbackend

/// A Swift `() -> Void` closure. Requires that `SwiftObject`'s wrapped value is
/// indeed of type `() -> Void`.
class SwiftAction(val closureObject: SwiftObject) {
    fun call() {
        callSwift()
    }

    external fun callSwift()
}
