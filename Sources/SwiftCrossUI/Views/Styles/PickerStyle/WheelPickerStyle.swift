/// A picker style that presents the options in a scrollable wheel.
///
/// Only supported by UIKitBakcned, and only when running on iOS 14+ or
/// Mac Catalyst 14+.
public struct WheelPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .wheel
    }
}

extension PickerStyle where Self == WheelPickerStyle {
    /// A picker style that presents the options in a scrollable wheel.
    ///
    /// Only supported by UIKitBakcned, and only when running on iOS 14+ or
    /// Mac Catalyst 14+.
    public static nonisolated var wheel: Self { Self() }
}
