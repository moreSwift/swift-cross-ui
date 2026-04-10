/// A scene's preferences. Propagated up the scene hierarchy automatically.
public struct ScenePreferenceValues {
    /// The default preferences.
    public static var `default`: ScenePreferenceValues {
        ScenePreferenceValues(commands: .empty)
    }

    /// The commands to be shown by the app.
    public var commands: Commands
}

extension ScenePreferenceValues {
    init(merging children: [ScenePreferenceValues]) {
        commands = children.map(\.commands).reduce(.empty) { $0.overlayed(with: $1) }
    }
}
