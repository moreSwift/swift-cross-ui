#if !os(WASI)
    import Foundation
#endif

/// A scene that presents a single window.
public struct Window<Content: View>: WindowingScene {
    public typealias Node = WindowNode<Content>

    /// The title of the window (shown in the title bar on most OSes).
    var title: String
    /// The window's content.
    var content: () -> Content
    /// The window's ID.
    ///
    /// This should never change after creation.
    let id: String

    /// Creates a window scene specifying a title and an ID.
    public init(
        _ title: String,
        id: String,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.id = id
        self.title = title
        self.content = content
    }
}

/// The ``SceneGraphNode`` corresponding to a ``Window`` scene.
public final class WindowNode<Content: View>: SceneGraphNode {
    public typealias NodeScene = Window<Content>

    /// The reference to the underlying window object, which also manages
    /// the window's view graph.
    ///
    /// `nil` if the window is closed.
    private var windowReference: WindowReference<Window<Content>>? = nil

    /// The underlying scene.
    private var scene: Window<Content>

    public init<Backend: AppBackend>(
        from scene: Window<Content>,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        self.scene = scene

        let openOnAppLaunch =
            switch environment.defaultLaunchBehavior {
                case .presented: true
                case .automatic, .suppressed: false
            }

        if openOnAppLaunch {
            self.windowReference = WindowReference(
                scene: scene,
                backend: backend,
                environment: environment,
                onClose: { self.windowReference = nil }
            )
        }
    }

    public func update<Backend: AppBackend>(
        _ newScene: Window<Content>?,
        backend: Backend,
        environment: EnvironmentValues
    ) -> SceneUpdateResult {
        if let newScene {
            self.scene = newScene
        }

        environment.openWindowFunctionsByID.value[scene.id] = { [weak self] in
            guard let self else { return }

            if let windowReference {
                // the window is already open: activate it
                windowReference.activate(backend: backend)
            } else {
                // the window is not open: create a new instance
                let reference = WindowReference(
                    scene: scene,
                    backend: backend,
                    environment: environment,
                    onClose: { self.windowReference = nil }
                )
                windowReference = reference

                _ = reference.update(
                    nil,
                    backend: backend,
                    environment: environment
                )
            }
        }

        return windowReference?.update(
            newScene,
            backend: backend,
            environment: environment
        ) ?? .leafScene()
    }
}
