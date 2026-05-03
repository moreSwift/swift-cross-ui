extension View {
    /// Sets the closability of the enclosing window.
    ///
    /// This only controls whether user can close the window via the title
    /// bar close button, built-in keyboard shortcuts such as Cmd+W or Alt+F4,
    /// etc. Windows can always be closed programmatically.
    public func windowDismissBehavior(_ behavior: WindowInteractionBehavior) -> some View {
        preference(key: \.windowDismissBehavior, value: behavior)
    }

    /// Sets the minimizability of the enclosing window.
    ///
    /// - Important: This isn't supported on GtkBackend or Gtk3Backend, both of
    ///   which ignore the corresponding preference value.
    public func preferredWindowMinimizeBehavior(
        _ behavior: WindowInteractionBehavior
    ) -> some View {
        preference(key: \.preferredWindowMinimizeBehavior, value: behavior)
    }

    /// Sets the resizability of the enclosing window.
    ///
    /// This modifier controls whether the user can resize the enclosing window,
    /// whereas ``Scene/windowResizability(_:)`` controls how SwiftCrossUI
    /// determines the bounds within which windows can be resized. The only time
    /// that ``Scene/windowResizability(_:)`` can disable interactive resizing
    /// is when the window's content has a fixed size and the
    /// ``WindowResizability`` is ``WindowResizability/contentSize``.
    public func windowResizeBehavior(_ behavior: WindowInteractionBehavior) -> some View {
        preference(key: \.windowResizeBehavior, value: behavior)
    }
}
