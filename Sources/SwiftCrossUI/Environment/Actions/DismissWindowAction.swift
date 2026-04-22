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
    let backend: any BaseAppBackend
    let window: MainActorBox<Any?>

    /// Closes the enclosing window.
    public func callAsFunction() {
        func closeWindow<Backend: BackendFeatures.Windowing>(backend: Backend) {
            guard let window = window.value else {
                logger.warning("dismissWindow() accessed outside of a window's scope")
                return
            }
            backend.close(window: window as! Backend.Window)
        }

        guard let backend = backend as? any BackendFeatures.Windowing else {
            logger.warning("\(type(of: backend)) doesn't support closing windows")
            return
        }
        closeWindow(backend: backend)
    }
}
