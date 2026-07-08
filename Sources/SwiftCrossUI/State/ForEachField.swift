// Adapted from https://github.com/swiftlang/swift/blob/swift-6.2.3-RELEASE/stdlib/public/core/ReflectionMirror.swift

// NB: I have absolutely zero clue why this is importable here. Xcode just shows
// me an empty file when I command-click it. Nevertheless, it works just fine and
// SourceKit seems to have no trouble finding stuff from here, so I'll roll
// with it for now.
private import SwiftShims

@_silgen_name("swift_reflectionMirror_recursiveCount")
private func getRecursiveChildCount(of: Any.Type) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
private func getChildOffset(of: Any.Type, index: Int) -> Int

@_silgen_name("swift_reflectionMirror_subscript")
private func getChild<T>(
    of: T,
    type: Any.Type,
    index: Int,
    outName: UnsafeMutablePointer<UnsafePointer<CChar>?>,
    outFreeFunc: UnsafeMutablePointer<NameFreeFunc?>
) -> Any

/// Calls the given closure on every field of the specified type.
///
/// The standard library exposes a function named `_forEachField(of:options:body:)` (used
/// [by Combine]), which calls directly into the runtime's reflection facilities in order to get
/// the names and types of the provided value's stored properties, bypassing most of the `Mirror`
/// overhead. However, it's annotated with `@_spi(Reflection)`, and most people's toolchain
/// installations don't include the stdlib's SPI interfaces. So we have to reimplement this
/// function ourselves.
///
/// There are three runtime functions used to implement this:
/// - `swift_reflectionMirror_recursiveCount(_:)`
/// - `swift_reflectionMirror_recursiveChildOffset(_:index:)`
/// - `swift_reflectionMirror_subscript(_:type:index:outName:outFreeFunc:)`
///
/// All three of these are public runtime API/ABI, as noted by the docs for the
/// [`SWIFT_RUNTIME_STDLIB_API`] C macro that they are annotated with.
///
/// - SeeAlso: The [original implementation] as of Swift 6.2.3.
///
/// [by Combine]: https://forums.swift.org/t/how-is-the-published-property-wrapper-implemented/58223/11
/// [original implementation]: https://github.com/swiftlang/swift/blob/swift-6.2.3-RELEASE/stdlib/public/core/ReflectionMirror.swift#L280-L284
/// [`SWIFT_RUNTIME_STDLIB_API`]: https://github.com/swiftlang/swift/blob/swift-6.2.3-RELEASE/stdlib/public/SwiftShims/swift/shims/Visibility.h#L265-L267
///
/// - Parameters:
///   - type: The type to inspect.
///   - body: A closure to call with information about each field in `type`.
///     The parameters to `body` are the name of the field, the offset of the
///     field, and the field's value.
func forEachField<Value>(
    of value: Value,
    body: (_ name: String?, _ offset: Int, _ fieldValue: Any) -> Void
) {
    let childCount = getRecursiveChildCount(of: Value.self)
    for index in 0..<childCount {
        let offset = getChildOffset(of: Value.self, index: index)

        var name: UnsafePointer<CChar>? = nil
        var freeFunc: NameFreeFunc? = nil
        defer { freeFunc?(name) }

        let childValue = getChild(
            of: value,
            type: Value.self,
            index: index,
            outName: &name,
            outFreeFunc: &freeFunc
        )

        body(name.flatMap(String.init(validatingCString:)), offset, childValue)
    }
}

/// > Safety: You must ensure that the `Base` type has a stored property at `offset` with a type of
/// > `Property` (or another type that can be safely bit-casted to `Property` for all possible
/// > values); breaking these invariants will cause undefined behavior.
func getProperty<Base, Property>(_: Property.Type, of base: Base, at offset: Int) -> Property {
    assert(offset + MemoryLayout<Property>.size <= MemoryLayout<Base>.size)
    return withUnsafeBytes(of: base) { buffer in
        buffer.baseAddress!.advanced(by: offset)
            .assumingMemoryBound(to: Property.self)
            .pointee
    }
}
