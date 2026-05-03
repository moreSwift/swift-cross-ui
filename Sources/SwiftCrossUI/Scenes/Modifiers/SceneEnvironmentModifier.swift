extension Scene {
    /// Modifies the scene's environment.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the environment value to update.
    ///   - newValue: The new value.
    public func environment<T>(
        _ keyPath: WritableKeyPath<EnvironmentValues, T>,
        _ newValue: T
    ) -> some Scene {
        SceneEnvironmentModifier(self) { environment in
            environment.with(keyPath, newValue)
        }
    }

    /// Modifies the scene's environment.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the environment value to update.
    ///   - transform: A closure that transforms the environment at `keyPath`.
    public func transformEnvironment<T>(
        _ keyPath: WritableKeyPath<EnvironmentValues, T>,
        transform: @escaping (inout T) -> Void
    ) -> some Scene {
        SceneEnvironmentModifier(self) { environment in
            var value = environment[keyPath: keyPath]
            transform(&value)
            return environment.with(keyPath, value)
        }
    }
}

struct SceneEnvironmentModifier<Content: Scene>: Scene {
    typealias Node = SceneEnvironmentModifierNode<Content>

    var content: Content
    var modification: (EnvironmentValues) -> EnvironmentValues

    init(
        _ content: Content,
        modification: @escaping (EnvironmentValues) -> EnvironmentValues
    ) {
        self.content = content
        self.modification = modification
    }
}

final class SceneEnvironmentModifierNode<Content: Scene>: SceneGraphNode {
    typealias NodeScene = SceneEnvironmentModifier<Content>

    var modification: (EnvironmentValues) -> EnvironmentValues
    var contentNode: Content.Node

    init<Backend: BaseAppBackend>(
        from scene: NodeScene,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        self.modification = scene.modification
        self.contentNode = Content.Node(
            from: scene.content,
            backend: backend,
            environment: modification(environment)
        )
    }

    func updateNode(
        _ newScene: NodeScene?,
        environment: EnvironmentValues
    ) -> SceneNodeUpdateResult {
        if let newScene {
            self.modification = newScene.modification
        }

        return contentNode.updateNode(
            newScene?.content,
            environment: modification(environment)
        )
    }

    func update<Backend: BaseAppBackend>(
        backend: Backend,
        environment: EnvironmentValues
    ) {
        contentNode.update(
            backend: backend,
            environment: modification(environment)
        )
    }
}
