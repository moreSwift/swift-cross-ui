extension View {
    /// Sets selectability of contained text. Ignored on tvOS.
    ///
    /// - Parameter isEnabled: Whether text selection is enabled.
    public func textSelectionEnabled(_ isEnabled: Bool = true) -> some View {
        EnvironmentModifier(
            self,
            modification: { environment in
                environment.with(\.isTextSelectionEnabled, isEnabled)
            }
        )
    }
}
