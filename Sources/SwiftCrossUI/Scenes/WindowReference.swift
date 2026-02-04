/// Holds the view graph and window handle for a single window.
@MainActor
final class WindowReference<SceneType: WindowingScene> {
    /// The scene.
    private var scene: SceneType
    /// The view graph of the window's root view.
    private let viewGraph: ViewGraph<SceneType.Content>
    /// The window being rendered in.
    private let window: Any
    /// `false` after the first scene update.
    private var isFirstUpdate = true
    /// The environment most recently provided by this node's parent scene.
    private var parentEnvironment: EnvironmentValues
    /// The container used to center the root view in the window.
    private let containerWidget: AnyWidget

    /// - Parameters:
    ///   - closeHandler: The action to perform when the window is closed. Should
    ///     dispose of the scene's reference to this `WindowReference`.
    init<Backend: AppBackend>(
        scene: SceneType,
        backend: Backend,
        environment: EnvironmentValues,
        onClose closeHandler: @escaping @Sendable @MainActor () -> Void
    ) {
        self.scene = scene
        let window = backend.createWindow(withDefaultSize: environment.defaultWindowSize)

        viewGraph = ViewGraph(
            for: scene.content(),
            backend: backend,
            environment: environment.with(\.window, window)
        )
        let rootWidget = viewGraph.rootNode.concreteNode(for: Backend.self).widget

        let container = backend.createContainer()
        backend.insert(rootWidget, into: container, at: 0)
        self.containerWidget = AnyWidget(container)

        backend.setChild(ofWindow: window, to: container)
        backend.setTitle(ofWindow: window, to: scene.title)

        self.window = window
        parentEnvironment = environment

        backend.setCloseHandler(ofWindow: window, to: closeHandler)

        backend.setResizeHandler(ofWindow: window) { [weak self] newSize in
            guard let self else { return }
            _ = self.update(
                self.scene,
                proposedWindowSize: newSize,
                needsWindowSizeCommit: false,
                backend: backend,
                environment: self.parentEnvironment,
                windowSizeIsFinal:
                    !backend.isWindowProgrammaticallyResizable(window)
            )
        }

        backend.setWindowEnvironmentChangeHandler(of: window) { [weak self] in
            guard let self else { return }
            _ = self.update(
                self.scene,
                proposedWindowSize: backend.size(ofWindow: window),
                needsWindowSizeCommit: false,
                backend: backend,
                environment: self.parentEnvironment,
                windowSizeIsFinal:
                    !backend.isWindowProgrammaticallyResizable(window)
            )
        }
    }

    func update<Backend: AppBackend>(
        _ newScene: SceneType?,
        backend: Backend,
        environment: EnvironmentValues
    ) -> SceneUpdateResult {
        guard let window = window as? Backend.Window else {
            fatalError("Scene updated with a backend incompatible with the window it was given")
        }

        let isProgramaticallyResizable =
            backend.isWindowProgrammaticallyResizable(window)

        let proposedWindowSize: SIMD2<Int>
        let usedDefaultSize: Bool
        if isFirstUpdate && isProgramaticallyResizable {
            proposedWindowSize = environment.defaultWindowSize
            usedDefaultSize = true
        } else {
            proposedWindowSize = backend.size(ofWindow: window)
            usedDefaultSize = false
        }

        return update(
            newScene,
            proposedWindowSize: proposedWindowSize,
            needsWindowSizeCommit: usedDefaultSize,
            backend: backend,
            environment: environment,
            windowSizeIsFinal: !isProgramaticallyResizable
        )
    }

    /// Updates the `WindowReference`.
    /// - Parameters:
    ///   - newScene: The scene. `nil` if this is the first update.
    ///   - proposedWindowSize: The proposed window size.
    ///   - needsWindowSizeCommit: Whether the proposed window size matches the
    ///     windows current size (or imminent size in the case of a window
    ///     resize). We use this parameter instead of comparing to the window's
    ///     current size to the proposed size, because some backends (such as
    ///     AppKitBackend) trigger window resize handlers *before* the underlying
    ///     window gets assigned its new size (allowing us to pre-emptively update the
    ///     window's content to match the new size).
    ///   - backend: The backend to use.
    ///   - environment: The current environment.
    ///   - windowSizeIsFinal: If true, no further resizes can/will be made. This
    ///     is true on platforms that don't support programmatic window resizing,
    ///     and when a window is full screen.
    private func update<Backend: AppBackend>(
        _ newScene: SceneType?,
        proposedWindowSize: SIMD2<Int>,
        needsWindowSizeCommit: Bool,
        backend: Backend,
        environment: EnvironmentValues,
        windowSizeIsFinal: Bool = false
    ) -> SceneUpdateResult {
        guard let window = window as? Backend.Window else {
            fatalError("Scene updated with a backend incompatible with the window it was given")
        }

        parentEnvironment = environment

        if let newScene {
            // Don't set default size even if it has changed. We only set that once
            // at window creation since some backends don't have a concept of
            // 'default' size which would mean that setting the default size every time
            // the default size changed would resize the window (which is incorrect
            // behaviour).
            backend.setTitle(ofWindow: window, to: newScene.title)
            scene = newScene
        }

        let environment =
            backend.computeWindowEnvironment(window: window, rootEnvironment: environment)
            .with(\.onResize) { [weak self] _ in
                guard let self else { return }
                // TODO: Figure out whether this would still work if we didn't recompute the
                //   scene's body. I have a vague feeling that it wouldn't work in all cases?
                //   But I don't have the time to come up with a counterexample right now.
                _ = self.update(
                    self.scene,
                    proposedWindowSize: backend.size(ofWindow: window),
                    needsWindowSizeCommit: false,
                    backend: backend,
                    environment: environment
                )
            }
            .with(\.window, window)

        let minimumWindowSize = viewGraph.computeLayout(
            with: newScene?.content(),
            proposedSize: .zero,
            environment: environment.with(\.allowLayoutCaching, true)
        ).size

        // With `.contentSize`, the window's maximum size is the maximum size of its
        // content. With `.contentMinSize` (and `.automatic`), there is no maximum
        // size.
        let maximumWindowSize: ViewSize? =
            switch environment.windowResizability {
                case .contentSize:
                    viewGraph.computeLayout(
                        with: newScene?.content(),
                        proposedSize: .infinity,
                        environment: environment.with(\.allowLayoutCaching, true)
                    ).size
                case .automatic, .contentMinSize:
                    nil
            }

        let clampedWindowSize = ViewSize(
            min(
                maximumWindowSize?.width ?? .infinity,
                max(minimumWindowSize.width, Double(proposedWindowSize.x))
            ),
            min(
                maximumWindowSize?.height ?? .infinity,
                max(minimumWindowSize.height, Double(proposedWindowSize.y))
            )
        )

        if clampedWindowSize.vector != proposedWindowSize && !windowSizeIsFinal {
            // Restart the window update if the content has caused the window to
            // change size.
            return update(
                scene,
                proposedWindowSize: clampedWindowSize.vector,
                needsWindowSizeCommit: true,
                backend: backend,
                environment: environment,
                windowSizeIsFinal: true
            )
        }

        // Set these even if the window isn't programmatically resizable
        // because the window may still be user resizable.
        backend.setSizeLimits(
            ofWindow: window,
            minimum: minimumWindowSize.vector,
            maximum: maximumWindowSize?.vector
        )

        let finalContentResult = viewGraph.computeLayout(
            proposedSize: ProposedViewSize(proposedWindowSize),
            environment: environment
        )

        viewGraph.commit()

        backend.setPosition(
            ofChildAt: 0,
            in: containerWidget.into(),
            to: (proposedWindowSize &- finalContentResult.size.vector) / 2
        )

        if needsWindowSizeCommit {
            backend.setSize(ofWindow: window, to: proposedWindowSize)
        }

        backend.setBehaviors(
            ofWindow: window,
            closable:
                finalContentResult.preferences.windowDismissBehavior?.isEnabled ?? true,
            minimizable:
                finalContentResult.preferences.preferredWindowMinimizeBehavior?.isEnabled ?? true,
            resizable:
                finalContentResult.preferences.windowResizeBehavior?.isEnabled ?? true
        )

        if isFirstUpdate {
            backend.show(window: window)
            isFirstUpdate = false
        }

        return .leafScene()
    }

    func activate<Backend: AppBackend>(backend: Backend) {
        guard let window = window as? Backend.Window else {
            fatalError("Scene updated with a backend incompatible with the window it was given")
        }

        backend.activate(window: window)
    }
}
