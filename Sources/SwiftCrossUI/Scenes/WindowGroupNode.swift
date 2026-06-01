/// The ``SceneGraphNode`` corresponding to a ``WindowGroup`` scene. Holds
/// the scene's view graph and window handle.
public final class WindowGroupNode<Content: View>: SceneGraphNode {
    public typealias NodeScene = WindowGroup<Content>

    /// The node's scene.
    private var scene: WindowGroup<Content>
    /// The view graph of the window group's root view. Will need to be multiple
    /// view graphs once having multiple copies of a window is supported.
    private var viewGraph: ViewGraph<Content>
    /// The window that the group is getting rendered in. Will need to be multiple
    /// windows once having multiple copies of a window is supported.
    private var window: Any
    /// `false` after the first scene update.
    private var isFirstUpdate = true
    /// The environment most recently provided by this node's parent scene.
    private var parentEnvironment: EnvironmentValues
    /// The container used to center the root view in the window.
    private var containerWidget: AnyWidget

    public init<Backend: AppBackend>(
        from scene: WindowGroup<Content>,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        self.scene = scene
        let window = backend.createWindow(withDefaultSize: scene.defaultSize)

        viewGraph = ViewGraph(
            for: scene.body,
            backend: backend,
            environment: environment.with(\.window, window)
        )
        let rootWidget = viewGraph.rootNode.concreteNode(for: Backend.self).widget

        let container = backend.createContainer()
        backend.addChild(rootWidget, to: container)
        self.containerWidget = AnyWidget(container)

        backend.setChild(ofWindow: window, to: container)
        backend.setTitle(ofWindow: window, to: scene.title)
        backend.setResizability(ofWindow: window, to: scene.resizability.isResizable)

        self.window = window
        parentEnvironment = environment

        backend.setResizeHandler(ofWindow: window) { newSize in
            _ = self.update(
                self.scene,
                proposedWindowSize: newSize,
                backend: backend,
                environment: self.parentEnvironment,
                windowSizeIsFinal:
                    !backend.isWindowProgrammaticallyResizable(window)
            )
        }

        backend.setWindowEnvironmentChangeHandler(of: window) {
            _ = self.update(
                self.scene,
                proposedWindowSize: backend.size(ofWindow: window),
                backend: backend,
                environment: self.parentEnvironment,
                windowSizeIsFinal:
                    !backend.isWindowProgrammaticallyResizable(window)
            )
        }
    }

    public func update<Backend: AppBackend>(
        _ newScene: WindowGroup<Content>?,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        guard let window = window as? Backend.Window else {
            fatalError("Scene updated with a backend incompatible with the window it was given")
        }

        let isProgramaticallyResizable =
            backend.isWindowProgrammaticallyResizable(window)

        _ = update(
            newScene,
            proposedWindowSize: isFirstUpdate && isProgramaticallyResizable
                ? (newScene ?? scene).defaultSize
                : backend.size(ofWindow: window),
            backend: backend,
            environment: environment,
            windowSizeIsFinal: !isProgramaticallyResizable
        )
    }

    public func update<Backend: AppBackend>(
        _ newScene: WindowGroup<Content>?,
        proposedWindowSize: SIMD2<Int>,
        backend: Backend,
        environment: EnvironmentValues,
        windowSizeIsFinal: Bool = false
    ) -> ViewUpdateResult {
        guard let window = window as? Backend.Window else {
            fatalError("Scene updated with a backend incompatible with the window it was given")
        }

        parentEnvironment = environment

        if let newScene = newScene {
            backend.setTitle(ofWindow: window, to: newScene.title)
            backend.setResizability(ofWindow: window, to: newScene.resizability.isResizable)
            scene = newScene
        }

        var newEnvironment = backend.computeWindowEnvironment(
            window: window,
            rootEnvironment: environment
        )

        // Assign onResize manually, strong capture
        newEnvironment.onResize = { _ in
            _ = self.update(
                self.scene,
                proposedWindowSize: backend.size(ofWindow: window),
                backend: backend,
                environment: newEnvironment
            )
        }

        // Assign window manually
        newEnvironment.window = window

        let environment = newEnvironment


        let dryRunResult: ViewUpdateResult?
        if !windowSizeIsFinal {
            let contentResult = viewGraph.update(
                with: newScene?.body,
                proposedSize: proposedWindowSize,
                environment: environment,
                dryRun: true
            )
            dryRunResult = contentResult

            let newWindowSize = computeNewWindowSize(
                currentProposedSize: proposedWindowSize,
                backend: backend,
                contentSize: contentResult.size,
                environment: environment
            )

            if let newWindowSize {
                return update(
                    scene,
                    proposedWindowSize: newWindowSize,
                    backend: backend,
                    environment: environment,
                    windowSizeIsFinal: false
                )
            }
        } else {
            dryRunResult = nil
        }

        let finalContentResult = viewGraph.update(
            with: newScene?.body,
            proposedSize: proposedWindowSize,
            environment: environment,
            dryRun: false
        )

        
        if let dryRunResult, finalContentResult.size != dryRunResult.size {
            print(
                """
                warning: Final window content size didn't match dry-run size. This is a sign that
                         either view size caching is broken or that backend.naturalSize(of:) is
                         broken (or both).
                      -> dryRunResult.size:       \(dryRunResult.size)
                      -> finalContentResult.size: \(finalContentResult.size)
                """
            )

            let newWindowSize = computeNewWindowSize(
                currentProposedSize: proposedWindowSize,
                backend: backend,
                contentSize: finalContentResult.size,
                environment: environment
            )

            if let newWindowSize {
                return update(
                    scene,
                    proposedWindowSize: newWindowSize,
                    backend: backend,
                    environment: environment,
                    windowSizeIsFinal: true
                )
            }
        }

        if scene.resizability.isResizable {
            backend.setMinimumSize(
                ofWindow: window,
                to: SIMD2(
                    finalContentResult.size.minimumWidth,
                    finalContentResult.size.minimumHeight
                )
            )
        }

        backend.setPosition(
            ofChildAt: 0,
            in: containerWidget.into(),
            to: SIMD2(
                (proposedWindowSize.x - finalContentResult.size.size.x) / 2,
                (proposedWindowSize.y - finalContentResult.size.size.y) / 2
            )
        )

        let currentWindowSize = backend.size(ofWindow: window)
        if currentWindowSize != proposedWindowSize {
            backend.setSize(ofWindow: window, to: proposedWindowSize)
        }

        if isFirstUpdate {
            backend.show(window: window)
            isFirstUpdate = false
        }

        return finalContentResult
    }

    public func computeNewWindowSize<Backend: AppBackend>(
        currentProposedSize: SIMD2<Int>,
        backend: Backend,
        contentSize: ViewSize,
        environment: EnvironmentValues
    ) -> SIMD2<Int>? {
        if scene.resizability.isResizable {
            if currentProposedSize.x < contentSize.minimumWidth
                || currentProposedSize.y < contentSize.minimumHeight
            {
                let newSize = SIMD2(
                    max(currentProposedSize.x, contentSize.minimumWidth),
                    max(currentProposedSize.y, contentSize.minimumHeight)
                )
                return newSize
            } else {
                return nil
            }
        } else if contentSize.idealSize != currentProposedSize {
            return contentSize.idealSize
        } else {
            return nil
        }
    }
}
