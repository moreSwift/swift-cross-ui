extension BackendFeatures {
    /// Backend methods for secure text fields.
    ///
    /// These are used by ``SecureField``.
    @MainActor
    public protocol SecureFields: Core {
        /// Creates an editable secure text field with a placeholder label and
        /// change handler.
        ///
        /// Predominantly used by ``SecureField``.
        ///
        /// - Returns: A secure text field.
        func createSecureField() -> Widget
        
        /// Sets the placeholder label and change handler of an editable secure
        /// text field.
        ///
        /// - Parameters:
        ///   - secureField: The secure text field to update.
        ///   - placeholder: The secure text field's placeholder label.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the secure text field's content
        ///     changes. This replaces any existing change handlers, and is called
        ///     whenever the displayed value changes.
        ///   - onSubmit: The action to perform when the user hits Enter/Return,
        ///     or whatever the backend decides counts as submission of the field.
        func updateSecureField(
            _ secureField: Widget,
            placeholder: String,
            environment: EnvironmentValues,
            onChange: @escaping (String) -> Void,
            onSubmit: @escaping () -> Void
        )

        /// Sets the value of an editable secure text field.
        ///
        /// - Parameters:
        ///   - secureField: The secure text field to set the content of.
        ///   - content: The new content.
        func setContent(ofSecureField secureField: Widget, to content: String)

        /// Gets the value of an editable secure text field.
        ///
        /// - Parameter secureField: The secure text field to get the content of.
        /// - Returns: `secureField`'s content.
        func getContent(ofSecureField secureField: Widget) -> String
    }
}
