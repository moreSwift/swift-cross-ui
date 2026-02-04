/// An action that dismisses the current presentation context.
///
/// Use the `dismiss` environment value to get an instance of this action,
/// then call it to dismiss (close) the enclosing sheet.
///
/// If you want to close the enclosing window, use ``EnvironmentValues/dismissWindow``
/// instead.
///
/// Example usage:
/// ```swift
/// struct SheetContentView: View {
///     @Environment(\.dismiss) var dismiss
///
///     var body: some View {
///         VStack {
///             Text("Sheet Content")
///             Button("Close") {
///                 dismiss()
///             }
///         }
///     }
/// }
/// ```
@MainActor
public struct DismissAction {
    private let action: @Sendable @MainActor () -> Void

    nonisolated internal init(action: @escaping @Sendable @MainActor () -> Void) {
        self.action = action
    }

    /// Dismisses the current presentation context.
    public func callAsFunction() {
        action()
    }
}

/// Environment key for the dismiss action.
private struct DismissActionKey: EnvironmentKey {
    static var defaultValue: DismissAction {
        DismissAction(action: {
            #if DEBUG
                logger.warning("dismiss() called but no presentation context is available")
            #endif
        })
    }
}

extension EnvironmentValues {
    /// An action that dismisses the current presentation context.
    ///
    /// Use this environment value to get a dismiss action that can be called
    /// to dismiss (close) the enclosing sheet, popover, or other presentation.
    ///
    /// If you want to close the enclosing window, use ``EnvironmentValues/dismissWindow``
    /// instead.
    ///
    /// Example:
    /// ```swift
    /// struct ContentView: View {
    ///     @Environment(\.dismiss) var dismiss
    ///
    ///     var body: some View {
    ///         Button("Close") {
    ///             dismiss()
    ///         }
    ///     }
    /// }
    /// ```
    @MainActor
    public var dismiss: DismissAction {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
}
