/// The default picker style that adapts to the current platform and context.
public struct DefaultPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: BaseAppBackend>(backend: Backend) -> BackendPickerStyle {
        backend.defaultPickerStyle
    }
}

extension PickerStyle where Self == DefaultPickerStyle {
    /// The default picker style that adapts to the current platform and context.
    public static nonisolated var automatic: Self { Self() }
}
