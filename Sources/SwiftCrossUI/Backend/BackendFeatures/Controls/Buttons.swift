extension BackendFeatures {
    /// Backend methods for buttons.
    ///
    /// These are used by ``Button`` and ``Menu``.
    @MainActor
    public protocol Buttons: Core {
        /// Creates a labelled button with an action triggered on click/tap.
        ///
        /// Predominantly used by ``Button``.
        ///
        /// - Returns: A button.
        func createButton() -> Widget

        /// Sets a button's label and action.
        ///
        /// - Parameters:
        ///   - button: The button to update.
        ///   - label: The button's label.
        ///   - environment: The current environment.
        ///   - action: The action to perform when the button is clicked/tapped.
        ///     This replaces any existing actions.
        func updateButton(
            _ button: Widget,
            label: String,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )
    }
}
