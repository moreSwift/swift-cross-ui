/// A picker style that shows its options inline within the picker's content.
///
/// Depending on the backend, this may appear as a radio group, a wheel picker,
/// or a segmented picker.
///
/// Only supported by AppKitBackend, UIKitBackend, and WinUIBackend.
public struct InlinePickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        // If the backend only supports .menu, or doesn't support pickers at
        // all, then inline pickers aren't supported regardless -- so it doesn't
        // matter which of the three is returned in that case.
        if backend.supportedPickerStyles.contains(.radioGroup) {
            .radioGroup
        } else if backend.supportedPickerStyles.contains(.wheel) {
            .wheel
        } else {
            .segmented
        }
    }
}

extension PickerStyle where Self == InlinePickerStyle {
    /// A picker style that shows its options inline within the picker's content.
    ///
    /// Depending on the backend, this may appear as a radio group, a wheel picker,
    /// or a segmented picker.
    ///
    /// Only supported by AppKitBackend, UIKitBackend, and WinUIBackend.
    public static nonisolated var inline: Self { Self() }
}
