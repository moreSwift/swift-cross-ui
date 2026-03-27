extension Scene {
    /// Controls how each window's resizing bounds relate to the resizability of the
    /// window's content.
    ///
    /// This modifier controls how SwiftCrossUI determines the bounds within which
    /// windows can be resized, whereas ``View/windowResizeBehavior(_:)`` controls
    /// whether the user can resize the enclosing window. The only time this
    /// modifier can disable interactive resizing is when a window's content has
    /// a fixed size and `resizability` is ``WindowResizability/contentSize``.
    public func windowResizability(_ resizability: WindowResizability) -> some Scene {
        environment(\.windowResizability, resizability)
    }
}
