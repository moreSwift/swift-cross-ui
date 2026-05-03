extension View {
    /// Set the content type of text fields.
    ///
    /// This controls autocomplete suggestions, and on mobile devices, which
    /// on-screen keyboard is shown.
    ///
    /// - Parameter type: The content type for text fields.
    public func textContentType(_ type: TextContentType) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.textContentType, type)
        }
    }
}
