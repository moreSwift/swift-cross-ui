/// Presents an alert to the user. Returns once an action has been selected and
/// the corresponding action handler has been run. Returns the index of the
/// selected action. By default, the alert will have a single button labelled
/// `OK`. All buttons will dismiss the alert even if you provide your own
/// actions.
@MainActor
public struct PresentAlertAction {
    let environment: EnvironmentValues

    // MARK: - iOS 13+ version with async/await
    /*@available(iOS 13.0, *)
    @discardableResult
    public func callAsFunction(
        _ title: String,
        @AlertActionsBuilder actions: () -> [AlertAction] = { [.ok] }
    ) async -> Int {
        let actions = actions()

        func presentAlert<Backend: AppBackend>(backend: Backend) async -> Int {
            await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let alert = backend.createAlert()
                    backend.updateAlert(
                        alert,
                        title: title,
                        actionLabels: actions.map(\.label),
                        environment: environment
                    )

                    let window: Backend.Window? = {
                        if let window = environment.window {
                            return window as? Backend.Window
                        }
                        return nil
                    }()

                    backend.showAlert(alert, window: window) { actionIndex in
                        actions[actionIndex].action()
                        continuation.resume(returning: actionIndex)
                    }
                }
            }
        }

        return await presentAlert(backend: environment.backend)
    }*/

    // MARK: - iOS 12 and below version with completion handler
    @discardableResult
    public func callAsFunction(
        _ title: String,
        @AlertActionsBuilder actions: () -> [AlertAction] = { [.ok] },
        completion: @escaping (Int) -> Void
    ) {
        let actions = actions()

        func presentAlert<Backend: AppBackend>(backend: Backend, completion: @escaping (Int) -> Void) {
            backend.runInMainThread {
                let alert = backend.createAlert()
                backend.updateAlert(
                    alert,
                    title: title,
                    actionLabels: actions.map(\.label),
                    environment: environment
                )

                let window: Backend.Window? = {
                    if let window = environment.window {
                        return window as? Backend.Window
                    }
                    return nil
                }()

                backend.showAlert(alert, window: window) { actionIndex in
                    actions[actionIndex].action()
                    completion(actionIndex)
                }
            }
        }

        presentAlert(backend: environment.backend, completion: completion)
    }
}
