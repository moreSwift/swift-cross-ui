/// A picker style that presents the options as a group of radio buttons.
///
/// Only supported by AppKitBackend and WinUIBackend.
public struct RadioGroupPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .radioGroup
    }
}

extension PickerStyle where Self == RadioGroupPickerStyle {
    /// A picker style that presents the options as a group of radio buttons.
    ///
    /// Only supported by AppKitBackend and WinUIBackend.
    public static nonisolated var radioGroup: Self { Self() }
}
