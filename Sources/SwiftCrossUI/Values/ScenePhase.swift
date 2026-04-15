/// A phase of a scene's lifecycle.
public struct ScenePhase: Hashable, Sendable {
    private enum Phase: Hashable, Sendable {
        case active
        case inactive
    }
    private var phase: Phase

    /// The scene is currently active.
    ///
    /// This indicates that the scene has focus and can recieve input events.
    public static let active = Self(phase: .active)
    /// The scene is currently inactive.
    ///
    /// This indicates that the scene does not have focus and does not recieve
    /// input events. The scene may or may not still be visible to the user.
    public static let inactive = Self(phase: .inactive)
}

extension ScenePhase: CustomStringConvertible {
    public var description: String {
        String(describing: phase)
    }
}
