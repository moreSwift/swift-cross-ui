// Adapted from https://github.com/swiftlang/swift/blob/swift-6.2.3-RELEASE/stdlib/public/core/ReflectionMirror.swift

// NB: I have absolutely zero clue why this is importable here. Xcode just shows
// me an empty file when I command-click it. Nevertheless, it works just fine and
// SourceKit seems to have no trouble finding stuff from here, so I'll roll
// with it for now.
private import SwiftShims

@_silgen_name("swift_reflectionMirror_recursiveCount")
private func _getRecursiveChildCount(_: Any.Type) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildMetadata")
private func _getChildMetadata(
    _: Any.Type,
    index: Int,
    fieldMetadata: UnsafeMutablePointer<_FieldReflectionMetadata>
) -> Any.Type

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
private func _getChildOffset(_: Any.Type, index: Int) -> Int

/// Calls the given closure on every field of the specified type.
///
/// The standard library exposes a function named `_forEachField(of:options:body:)`,
/// which calls directly into the runtime's reflection facilities in order to
/// get the names and types of the provided value's stored properties, bypassing
/// most of the `Mirror` overhead. However, it's annotated with `@_spi(Reflection)`,
/// and most people's toolchain installations don't include the stdlib's SPI
/// interfaces. So we have to reimplement this function ourselves.
///
/// There are three runtime functions used to implement this:
/// - `swift_reflectionMirror_recursiveCount(_:)`
/// - `swift_reflectionMirror_recursiveChildMetadata(_:index:fieldMetadata:)`
/// - `swift_reflectionMirror_recursiveChildOffset(_:index:)`
///
/// All three of these have been present in the runtime for at least 6 years (probably
/// longer), and since `_forEachField(of:options:body:)` is used [within Combine] (and
/// presumably other Apple frameworks), it's fairly unlikely that either it or the
/// functions it depends on (which are the same as shown above) will be removed any
/// time soon.
///
/// - SeeAlso: The [original implementation] as of Swift 6.2.3.
///
/// [within Combine]: https://forums.swift.org/t/how-is-the-published-property-wrapper-implemented/58223/11
/// [original implementation]: https://github.com/swiftlang/swift/blob/swift-6.2.3-RELEASE/stdlib/public/core/ReflectionMirror.swift
///
/// - Parameters:
///   - type: The type to inspect.
///   - body: A closure to call with information about each field in `type`.
///     The parameters to `body` are the name of the field, the offset of the
///     field, and the type of the field.
func _forEachField(of type: Any.Type, body: (String?, Int, Any.Type) -> Void) {
    let childCount = _getRecursiveChildCount(type)
    for index in 0..<childCount {
        let offset = _getChildOffset(type, index: index)

        var field = _FieldReflectionMetadata()
        let childType = _getChildMetadata(type, index: index, fieldMetadata: &field)
        defer { field.freeFunc?(field.name) }

        body(field.name.flatMap(String.init(validatingCString:)), offset, childType)
    }
}
