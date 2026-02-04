/// The launch behavior for a scene.
public enum SceneLaunchBehavior: Sendable {
    /// SwiftCrossUI decides whether to use ``presented`` or ``suppressed``
    /// depending on the type of scene.
    ///
    /// Currently, `presented` is used for ``WindowGroup``s, and
    /// `suppressed` is used for ``Window``s.
    case automatic
    /// The scene will be shown on app launch.
    case presented
    /// The scene will not be shown on app launch.
    case suppressed
}
