extension BackendFeatures {
    /// Backend methods for checkboxes.
    ///
    /// These are used by ``Toggle`` when ``EnvironmentValues/toggleStyle`` is
    /// ``ToggleStyle/checkbox``.
    @MainActor
    public protocol Checkboxes: Core {
        /// Creates a checkbox that is either on or off.
        ///
        /// - Returns: A checkbox.
        func createCheckbox() -> Widget

        /// Sets the change handler of a checkbox.
        ///
        /// - Parameters:
        ///   - checkboxWidget: The checkbox to update.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the checkbox is toggled on or
        ///     off. This replaces any existing change handlers.
        func updateCheckbox(
            _ checkboxWidget: Widget,
            environment: EnvironmentValues,
            onChange: @escaping (Bool) -> Void
        )

        /// Sets the state of a checkbox.
        ///
        /// - Parameters:
        ///   - checkboxWidget: The checkbox to set the state of.
        ///   - state: The new state.
        func setState(ofCheckbox checkboxWidget: Widget, to state: Bool)
    }
}
