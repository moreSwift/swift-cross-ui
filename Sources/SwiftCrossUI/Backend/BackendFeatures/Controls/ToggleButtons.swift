extension BackendFeatures {
    /// Backend methods for toggle buttons.
    ///
    /// These are used by ``Toggle`` when ``EnvironmentValues/toggleStyle`` is
    /// ``ToggleStyle/button``.
    @MainActor
    public protocol ToggleButtons: Core {
        /// Creates a labelled toggle that is either on or off.
        ///
        /// - Returns: A toggle.
        func createToggle() -> Widget

        /// Sets the label and change handler of a toggle.
        ///
        /// - Parameters:
        ///   - toggle: The toggle to update.
        ///   - label: The toggle's label.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the button is toggled on or
        ///     off. This replaces any existing change handlers.
        func updateToggle(
            _ toggle: Widget,
            label: String,
            environment: EnvironmentValues,
            onChange: @escaping (Bool) -> Void
        )

        /// Sets the state of a toggle.
        ///
        /// - Parameters:
        ///   - toggle: The toggle to set the state of.
        ///   - state: The new state.
        func setState(ofToggle toggle: Widget, to state: Bool)
    }
}
