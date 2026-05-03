extension View {
    /// Sets the color scheme for this view.
    ///
    /// - Parameter colorScheme: The color scheme to set.
    public func colorScheme(_ colorScheme: ColorScheme) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.colorScheme, colorScheme)
        }
    }
}
