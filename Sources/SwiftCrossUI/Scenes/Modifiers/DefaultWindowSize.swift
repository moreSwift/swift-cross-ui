extension Scene {
    /// Sets the default size of windows controlled by this scene.
    ///
    /// Used when creating new window instances.
    public func defaultSize(width: Int, height: Int) -> some Scene {
        environment(\.defaultWindowSize, SIMD2(width, height))
    }
}
