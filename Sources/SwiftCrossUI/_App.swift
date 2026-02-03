// TODO: This could possibly be renamed to ``SceneGraph`` now that that's basically the role
//   it has taken on since introducing scenes.
/// A top-level wrapper providing an entry point for the app. Exists to be able to persist
/// the view graph alongside the app (we can't do that on a user's `App` implementation because
/// we can only add computed properties).
@MainActor
class _App<AppRoot: App> {
    /// The app being run.
    let app: AppRoot
    /// An instance of the app's selected backend.
    let backend: AppRoot.Backend
    /// The root of the app's scene graph.
    var sceneGraphRoot: AppRoot.Body.Node?
    /// Cancellables for observations of the app's state properties.
    var cancellables: [Cancellable]
    /// The root level environment.
    var environment: EnvironmentValues
    /// The dynamic property updater for ``app``.
    var dynamicPropertyUpdater: DynamicPropertyUpdater<AppRoot>

    /// Wraps a user's app implementation.
    init(_ app: AppRoot) {
        backend = app.backend
        self.app = app
        self.environment = EnvironmentValues(
            backend: backend,
            appStorageProvider: app.appStorageProvider
        )
        self.cancellables = []

        dynamicPropertyUpdater = DynamicPropertyUpdater(for: app)
    }

    func refreshSceneGraph() {
        // TODO: Do we have to update dynamic properties on state changes?
        //   We can probably get away with only doing it when the root
        //   environment changes.
        dynamicPropertyUpdater.update(app, with: environment, previousValue: nil)

        if let sceneGraphRoot {
            let result = sceneGraphRoot.update(
                app.body,
                backend: backend,
                environment: environment
            )
            backend.setApplicationMenu(result.preferences.commands.resolve())
        }
    }

    /// Runs the app using the app's selected backend.
    func run() {
        backend.runMainLoop { [self] in
            let baseEnvironment = EnvironmentValues(
                backend: backend,
                appStorageProvider: app.appStorageProvider
            )
            environment = backend.computeRootEnvironment(
                defaultEnvironment: baseEnvironment
            )

            dynamicPropertyUpdater.update(app, with: environment, previousValue: nil)

            let mirror = Mirror(reflecting: app)
            for property in mirror.children {
                if property.label == "state" && property.value is ObservableObject {
                    logger.warning(
                        """
                        the App.state protocol requirement has been removed in favour of \
                        SwiftUI-style @State annotations; decorate \(AppRoot.self).state \
                        with the @State property wrapper to restore previous behaviour
                        """
                    )
                }

                guard let value = property.value as? any ObservableProperty else {
                    continue
                }

                let cancellable =
                    value.didChange.observeAsUIUpdater(backend: backend) { [weak self] in
                        self?.refreshSceneGraph()
                    }
                cancellables.append(cancellable)
            }

            let rootNode = AppRoot.Body.Node(
                from: app.body,
                backend: backend,
                environment: environment
            )

            backend.setRootEnvironmentChangeHandler {
                self.environment = self.backend.computeRootEnvironment(
                    defaultEnvironment: baseEnvironment
                )
                self.refreshSceneGraph()
            }

            let result = rootNode.update(
                nil,
                backend: backend,
                environment: backend.computeRootEnvironment(
                    defaultEnvironment: baseEnvironment
                )
            )
            self.sceneGraphRoot = rootNode

            // Update application-wide menu
            backend.setApplicationMenu(result.preferences.commands.resolve())
        }
    }
}
