/// Presents an alert to the user.
///
/// Returns once an action has been selected and the corresponding action
/// handler has been run. Returns the index of the selected action. By default,
/// the alert will have a single button labelled "OK". All buttons will dismiss
/// the alert even if you provide your own actions.
@MainActor
public struct PresentAlertAction {
    let environment: EnvironmentValues

    /// Presents an alert to the user.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - actions: A list of actions the user can perform.
    /// - Returns: The index of the chosen action.
    @discardableResult
    public func callAsFunction(
        _ title: String,
        @AlertActionsBuilder actions: () -> [AlertAction] = { [.default] }
    ) async -> Int {
        let actions = actions()

        func presentAlert<Backend: BackendFeatures.Alerts>(backend: Backend) async -> Int {
            await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let alert = backend.createAlert()
                    backend.updateAlert(
                        alert,
                        title: title,
                        actionLabels: actions.map(\.label),
                        environment: environment
                    )
                    let window = environment.window.map { $0 as! Backend.Window }
                    backend.showAlert(alert, window: window) { actionIndex in
                        actions[actionIndex].action()
                        continuation.resume(returning: actionIndex)
                    }
                }
            }
        }

        guard let backend = environment.backend as? any BackendFeatures.Alerts else {
            fatalError("\(type(of: environment.backend)) does not support alerts")
        }
        return await presentAlert(backend: backend)
    }
}
