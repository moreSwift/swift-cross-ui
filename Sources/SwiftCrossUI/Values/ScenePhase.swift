/// A phase of a scene's lifecycle.
public enum ScenePhase: Hashable, Sendable {
    /// The scene is currently active.
    ///
    /// This indicates that the scene has focus and can recieve input events.
    case active
    /// The scene is currently inactive.
    ///
    /// This indicates that the scene does not have focus and does not recieve
    /// input events.
    case inactive
}
