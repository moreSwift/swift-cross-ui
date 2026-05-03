extension BackendFeatures {
    /// Backend methods for text fields.
    ///
    /// These are used by ``TextField``.
    @MainActor
    public protocol TextFields: Core {
        /// Creates an editable text field with a placeholder label and change
        /// handler.
        ///
        /// Predominantly used by ``TextField``.
        ///
        /// - Returns: A text field.
        func createTextField() -> Widget

        /// Sets the placeholder label and change handler of an editable text field.
        ///
        /// - Parameters:
        ///   - textField: The text field to update.
        ///   - placeholder: The text field's placeholder label.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the text field's content
        ///     changes. This replaces any existing change handlers, and is called
        ///     whenever the displayed value changes.
        ///   - onSubmit: The action to perform when the user hits Enter/Return,
        ///     or whatever the backend decides counts as submission of the field.
        func updateTextField(
            _ textField: Widget,
            placeholder: String,
            environment: EnvironmentValues,
            onChange: @escaping (String) -> Void,
            onSubmit: @escaping () -> Void
        )

        /// Sets the value of an editable text field.
        ///
        /// - Parameters:
        ///   - textField: The text field to set the content of.
        ///   - content: The new content.
        func setContent(ofTextField textField: Widget, to content: String)

        /// Gets the value of an editable text field.
        ///
        /// - Parameter textField: The text field to get the content of.
        /// - Returns: `textField`'s content.
        func getContent(ofTextField textField: Widget) -> String
    }
}
