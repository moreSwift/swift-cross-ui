import Foundation

/// A scene that presents a group of identically structured windows.
public struct WindowGroup<Content: View>: WindowingScene {
    public typealias Node = WindowGroupNode<Content>

    /// The title of the window (shown in the title bar on most OSes).
    var title: String
    /// The window's content.
    var content: () -> Content
    /// The window's ID.
    ///
    /// This should never change after creation.
    let id: String?

    /// Creates a window group optionally specifying a title and an ID. Window title
    /// defaults to `ProcessInfo.processInfo.processName`.
    public init(
        _ title: String? = nil,
        id: String? = nil,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        #if os(WASI)
            let title = title ?? "Title"
        #else
            let title = title ?? ProcessInfo.processInfo.processName
        #endif
        self.id = id
        self.title = title
        self.content = content
    }
}

/// The ``SceneGraphNode`` corresponding to a ``WindowGroup`` scene.
public final class WindowGroupNode<Content: View>: SceneGraphNode {
    public typealias NodeScene = WindowGroup<Content>

    /// The references to the underlying window objects, which also manage
    /// each window's view graph.
    ///
    /// Empty if there are currently no instances of the window.
    private var windowReferences: [UUID: WindowReference<WindowGroup<Content>>] = [:]

    /// The underlying scene.
    private var scene: WindowGroup<Content>

    public init<Backend: AppBackend>(
        from scene: WindowGroup<Content>,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        self.scene = scene

        let openOnAppLaunch =
            switch environment.defaultLaunchBehavior {
                case .automatic, .presented: true
                case .suppressed: false
            }

        if openOnAppLaunch {
            let windowID = UUID()
            self.windowReferences = [
                windowID: WindowReference(
                    scene: scene,
                    backend: backend,
                    environment: environment,
                    onClose: { self.windowReferences[windowID] = nil }
                )
            ]
        }
    }

    public func update<Backend: AppBackend>(
        _ newScene: WindowGroup<Content>?,
        backend: Backend,
        environment: EnvironmentValues
    ) -> SceneUpdateResult {
        if let newScene {
            self.scene = newScene
        }

        if let id = scene.id {
            environment.openWindowFunctionsByID.value[id] = { [weak self] in
                guard let self else { return }

                let windowID = UUID()
                let reference = WindowReference(
                    scene: scene,
                    backend: backend,
                    environment: environment,
                    onClose: { self.windowReferences[windowID] = nil }
                )
                windowReferences[windowID] = reference

                _ = reference.update(
                    nil,
                    backend: backend,
                    environment: environment
                )
            }
        }

        let results = windowReferences.values.map { windowReference in
            windowReference.update(
                newScene,
                backend: backend,
                environment: environment
            )
        }
        return SceneUpdateResult(childResults: results)
    }
}
