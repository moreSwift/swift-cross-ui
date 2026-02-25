/// A picker style that presents the options in a horizontal segmented control.
///
/// Only supported by UIKitBackend and AppKitBackend.
public struct SegmentedPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .segmented
    }
}

extension PickerStyle where Self == SegmentedPickerStyle {
    /// A picker style that presents the options in a horizontal segmented control.
    ///
    /// Only supported by UIKitBackend and AppKitBackend.
    public static nonisolated var segmented: Self { Self() }

    /// An alias for ``PickerStyle/segmented``, provided for SwiftUI compatibility.
    ///
    /// Only supported by UIKitBackend and AppKitBackend.
    public static nonisolated var palette: Self { Self() }
}
