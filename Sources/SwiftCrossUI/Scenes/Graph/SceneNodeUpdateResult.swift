/// The result of updating a scene graph node.
public struct SceneNodeUpdateResult: Sendable {
    /// The preference values produced by the scene and its children.
    public var preferences: ScenePreferenceValues

    public init(preferences: ScenePreferenceValues) {
        self.preferences = preferences
    }

    /// Creates an update result by combining the preference values of a scene's
    /// children.
    public init(childResults: [SceneNodeUpdateResult]) {
        preferences = ScenePreferenceValues(merging: childResults.map(\.preferences))
    }

    /// Creates the layout result of a leaf scene (one with no children and no
    /// special preference behaviour). Uses ``ScenePreferenceValues/default``.
    public static func leafScene() -> Self {
        SceneNodeUpdateResult(preferences: .default)
    }
}
