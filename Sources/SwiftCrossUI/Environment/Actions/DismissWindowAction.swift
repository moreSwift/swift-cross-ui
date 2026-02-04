/// An action that closes the enclosing window.
///
/// Use the ``EnvironmentValues/dismissWindow`` environment value to get an instance
/// of this action, then call it to close the enclosing window.
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @Environment(\.dismissWindow) var dismissWindow
///
///     var body: some View {
///         VStack {
///             Text("Window Content")
///             Button("Close") {
///                 dismissWindow()
///             }
///         }
///     }
/// }
/// ```
@MainActor
public struct DismissWindowAction {
    let backend: any AppBackend
    let window: MainActorBox<Any?>

    /// Closes the enclosing window.
    public func callAsFunction() {
        func closeWindow<Backend: AppBackend>(backend: Backend) {
            guard let window = window.value else {
                logger.warning("dismissWindow() accessed outside of a window's scope")
                return
            }
            backend.close(window: window as! Backend.Window)
        }

        closeWindow(backend: backend)
    }
}
