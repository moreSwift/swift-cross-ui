/// A persistent representation of a scene that maintains its state even when
/// the scene itself gets recomputed.
///
/// This is required to store view graphs, widget handles, etc.
///
/// Treat scenes as basic data structures that simply encode the structure of
/// the app; the actual rendering and logic is handled by the node.
@MainActor
public protocol SceneGraphNode: AnyObject {
    /// The type of scene managed by this node.
    associatedtype NodeScene: Scene where NodeScene.Node == Self

    /// Creates a node from a corresponding scene.
    ///
    /// Should perform initial setup of any widgets required to display the
    /// scene (although ``SceneGraphNode/update(backend:environment:)`` is
    /// guaranteed to be called immediately after initialization).
    ///
    /// - Parameters:
    ///   - scene: The scene to create the node from.
    ///   - backend: The app's backend.
    ///   - environment: The current root-level environment.
    init<Backend: BaseAppBackend>(
        from scene: NodeScene,
        backend: Backend,
        environment: EnvironmentValues
    )

    /// Updates the scene's node without committing anything to screen or
    /// propagating the update to child views.
    ///
    /// - Parameters:
    ///   - newScene: The recomputed scene if the update is due to it being
    ///     recomputed.
    ///   - environment: The current root-level environment.
    /// - Returns: The result of updating the scene node.
    func updateNode(
        _ newScene: NodeScene?,
        environment: EnvironmentValues
    ) -> SceneNodeUpdateResult

    /// Updates the scene.
    ///
    /// Unlike views (which have state), scenes are only ever updated when
    /// they're recomputed or immediately after they're created.
    ///
    /// - Parameters:
    ///   - backend: The app's backend.
    ///   - environment: The current environment.
    func update<Backend: BaseAppBackend>(
        backend: Backend,
        environment: EnvironmentValues
    )
}
