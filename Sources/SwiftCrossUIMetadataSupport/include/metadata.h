/// Returns an untyped pointer to a Swift `[[UInt8]]` containing
/// UTF8-encoded JSON data in its first element.
///
/// This function bridges to Swift as:
///
/// ```swift
/// func _getSwiftBundlerMetadata() -> UnsafeRawPointer?
/// ```
///
/// The metadata can be accessed by binding the returned pointer to `[[UInt8]]`:
///
/// ```swift
/// guard let pointer = _getSwiftBundlerMetadata() else { return }
/// let datas = pointer.assumingMemoryBound(to: [[UInt8]].self).pointee
/// ```
///
/// > Important: Attempting to call this function when it has not been linked in
/// > by swift-bundler will cause linking to fail. To prevent this, wrap all code
/// > paths relying on this function in:
/// >
/// > ```swift
/// > #if SWIFT_BUNDLER_METADATA
/// >   // ...
/// > #endif
/// > ```
const void * _Nullable _getSwiftBundlerMetadata();
