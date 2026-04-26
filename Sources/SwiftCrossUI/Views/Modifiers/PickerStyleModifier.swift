extension View {
    /// Sets the picker style for views.
    ///
    /// - Parameter style: The picker style to use.
    ///
    /// ## See Also
    ///
    /// - ``PickerStyle``
    public func pickerStyle(_ style: any PickerStyle) -> some View {
        EnvironmentModifier(self) { environment in
            if !style.isSupported(backend: environment.backend) {
                assertionFailure(
                    "Picker style \(style) not supported by backend \(type(of: environment.backend))"
                )
                return environment.with(\.pickerStyle, .automatic)
            }
            return environment.with(\.pickerStyle, style)
        }
    }
}
