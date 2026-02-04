/// A scene that shows a standalone alert.
///
/// The exact behavior of the alert is backend-dependent, but it typically
/// shows up as an application modal, or attaches itself to the app's main
/// window.
public struct AlertScene: Scene {
    public typealias Node = AlertSceneNode

    var title: String
    @Binding var isPresented: Bool
    var actions: [AlertAction]

    /// Creates an alert scene.
    ///
    /// The exact behavior of the alert is backend-dependent, but it typically
    /// shows up as an application modal, or attaches itself to the app's main
    /// window.
    ///
    /// - Parameters:
    ///   - title: The alert's title.
    ///   - isPresented: A binding to a `Bool` that controls whether the alert
    ///     is presented.
    ///   - actions: The alert's actions.
    public init(
        _ title: String,
        isPresented: Binding<Bool>,
        @AlertActionsBuilder actions: () -> [AlertAction]
    ) {
        self.title = title
        self._isPresented = isPresented
        self.actions = actions()
    }
}

/// The scene graph node for ``AlertScene``.
public final class AlertSceneNode: SceneGraphNode {
    public typealias NodeScene = AlertScene

    private var scene: AlertScene
    private var alert: Any?

    public init<Backend: AppBackend>(
        from scene: AlertScene,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        self.scene = scene
    }

    public func update<Backend: AppBackend>(
        _ newScene: AlertScene?,
        backend: Backend,
        environment: EnvironmentValues
    ) -> SceneUpdateResult {
        if let newScene {
            self.scene = newScene
        }

        if scene.isPresented, alert == nil {
            let alert = backend.createAlert()
            backend.updateAlert(
                alert,
                title: scene.title,
                actionLabels: scene.actions.map(\.label),
                environment: environment
            )
            backend.showAlert(alert, window: nil) { responseId in
                self.alert = nil
                self.scene.isPresented = false
                self.scene.actions[responseId].action()
            }

            self.alert = alert
        } else if !scene.isPresented, let alert {
            backend.dismissAlert(alert as! Backend.Alert, window: nil)
            self.alert = nil
        }

        return .leafScene()
    }
}
