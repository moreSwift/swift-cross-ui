extension View {
    /// Sets the app storage provider used to persist state annotated
    /// with ``AppStorage``.
    ///
    /// - Parameter provider: The app storage provider to use in this
    ///   view and its subviews.
    public func appStorageProvider(_ provider: some AppStorageProvider) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.appStorageProvider, provider)
        }
    }
}
