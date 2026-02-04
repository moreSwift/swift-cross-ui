/// A scene that represents one or more windows.
///
/// This is needed so we can share the `WindowReference` code between ``Window``
/// and ``WindowGroup`` (as well as any other windowing scenes we decide to
/// add in the future), without having to awkwardly abstract the window state
/// into a separate `struct`.
protocol WindowingScene: Scene {
    associatedtype Content: View
    /// The title for all windows managed by this scene.
    var title: String { get }
    /// The content of all windows managed by this scene.
    ///
    /// Each window should have its own state copy.
    var content: () -> Content { get }
}
