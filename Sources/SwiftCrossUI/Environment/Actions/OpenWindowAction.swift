/// An action that opens a window with the specified ID.
@MainActor
public struct OpenWindowAction {
    let environment: EnvironmentValues

    /// Opens the window with the specified ID.
    public func callAsFunction(id: String) {
        guard environment.backend.supportsMultipleWindows else {
            logger.warning(
                """
                openWindow(id:) called but the backend doesn't support \
                multi-window, ignoring
                """
            )
            return
        }

        guard let openWindow = environment.openWindowFunctionsByID.value[id] else {
            logger.warning(
                """
                openWindow(id:) called with an ID that does not have an \
                associated window
                """,
                metadata: ["id": "\(id)"]
            )
            return
        }
        openWindow()
    }
}
