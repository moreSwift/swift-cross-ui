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

    /// Wraps a user's app implementation.
    init(_ app: AppRoot) {
        backend = app.backend
        self.app = app
        self.environment = EnvironmentValues(backend: backend)
        self.cancellables = []
    }

    func forceRefresh() {
        updateDynamicProperties(
            of: self.app,
            previousValue: nil,
            environment: self.environment
        )

        self.sceneGraphRoot?.update(
            self.app.body,
            backend: self.backend,
            environment: environment
        )
    }

    /// Runs the app using the app's selected backend.
    func run() {
        backend.runMainLoop {
            let baseEnvironment = EnvironmentValues(backend: self.backend)
            self.environment = self.backend.computeRootEnvironment(
                defaultEnvironment: baseEnvironment
            )

            updateDynamicProperties(
                of: self.app,
                previousValue: nil,
                environment: self.environment
            )

            let mirror = Mirror(reflecting: self.app)
            for property in mirror.children {
                if property.label == "state" && property.value is ObservableObject {
                    print(
                        """

                        warning: The App.state protocol requirement has been removed in favour of
                                 SwiftUI-style @State annotations. Decorate \(AppRoot.self).state
                                 with the @State property wrapper to restore previous behaviour.

                        """
                    )
                }

                guard let value = property.value as? StateProperty else {
                    continue
                }

                let cancellable = value.didChange.observeAsUIUpdater(backend: self.backend) {
                    [weak self] in
                    guard let self = self else { return }

                    updateDynamicProperties(
                        of: self.app,
                        previousValue: nil,
                        environment: self.environment
                    )

                    let body = self.app.body
                    self.sceneGraphRoot?.update(
                        body,
                        backend: self.backend,
                        environment: self.environment
                    )

                    //self.backend.setApplicationMenu(body.commands.resolve())
                }
                self.cancellables.append(cancellable)
            }

            let body = self.app.body
            let rootNode = AppRoot.Body.Node(
                from: body,
                backend: self.backend,
                environment: self.environment
            )

            self.backend.setRootEnvironmentChangeHandler {
                self.environment = self.backend.computeRootEnvironment(
                    defaultEnvironment: baseEnvironment
                )
                self.forceRefresh()
            }

            // Update application-wide menu
            //self.backend.setApplicationMenu(body.commands.resolve())

            rootNode.update(
                nil,
                backend: self.backend,
                environment: self.backend.computeRootEnvironment(
                    defaultEnvironment: baseEnvironment
                )
            )
            self.sceneGraphRoot = rootNode
        }
    }
}
