extension View {
    /// Sets the app storage provider used to persist state annotated
    /// with ``AppStorage``.
    ///
    /// - Parameter provider: The app storage provider to use in this
    ///   view and its subviews.
    public func appStorageProvider(_ provider: some AppStorageProvider) -> some View {
        environment(\.appStorageProvider, provider)
    }
}

extension Scene {
    /// Sets the app storage provider used to persist state annotated
    /// with ``AppStorage``.
    ///
    /// - Parameter provider: The app storage provider to use in this
    ///   scene and its subviews.
    public func appStorageProvider(_ provider: some AppStorageProvider) -> some Scene {
        environment(\.appStorageProvider, provider)
    }
}
