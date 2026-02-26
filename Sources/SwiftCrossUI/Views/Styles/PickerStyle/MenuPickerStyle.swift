/// A picker style that presents the options in a drop-down menu.
///
/// Supported by GtkBackend, AppKitBackend, and WinUIBackend. Supported by
/// UIKitBackend when running on tvOS 17+, iOS 14+, or Mac Catalyst 14+.
public struct MenuPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .menu
    }
}

extension PickerStyle where Self == MenuPickerStyle {
    /// A picker style that presents the options in a drop-down menu.
    ///
    /// Supported by GtkBackend, AppKitBackend, and WinUIBackend. Supported by
    /// UIKitBackend when running on tvOS 17+, iOS 14+, or Mac Catalyst 14+.
    public static nonisolated var menu: Self { Self() }
}
