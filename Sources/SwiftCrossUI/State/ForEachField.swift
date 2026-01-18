//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@_silgen_name("swift_reflectionMirror_recursiveCount")
private func _getRecursiveChildCount(_: Any.Type) -> Int

@_silgen_name("swift_reflectionMirror_recursiveChildOffset")
private func _getChildOffset(_: Any.Type, index: Int) -> Int

private typealias NameFreeFunc = @convention(c) (UnsafePointer<CChar>?) -> Void

@_silgen_name("swift_reflectionMirror_subscript")
private func _getChild<T>(
    of: T,
    type: Any.Type,
    index: Int,
    outName: UnsafeMutablePointer<UnsafePointer<CChar>?>,
    outFreeFunc: UnsafeMutablePointer<NameFreeFunc?>
) -> Any

/// Calls the given closure on every field of the specified value.
///
/// - Parameters:
///   - value: The value to inspect.
///   - body: A closure to call with information about each field in `value`.
///     The parameters to `body` are the name of the field, the offset of the
///     field, and the value of the field.
func _forEachField<Value>(of value: Value, body: (String?, Int, Any) -> Void) {
    let childCount = _getRecursiveChildCount(Value.self)
    for index in 0..<childCount {
        let offset = _getChildOffset(Value.self, index: index)

        var nameC: UnsafePointer<CChar>? = nil
        var freeFunc: NameFreeFunc? = nil
        defer { freeFunc?(nameC) }

        let childValue = _getChild(
            of: value,
            type: Value.self,
            index: index,
            outName: &nameC,
            outFreeFunc: &freeFunc
        )
        let childName = nameC.flatMap(String.init(validatingCString:))

        body(childName, offset, childValue)
    }
}
