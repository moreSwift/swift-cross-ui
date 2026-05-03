extension View {
    /// Disables user interaction in any subviews that support disabling
    /// interaction.
    ///
    /// - Parameter disabled: Whether to disable user interaction.
    public func disabled(_ disabled: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.isEnabled, !disabled)
        }
    }
}
