extension BackendFeatures {
    /// Backend methods for text editors.
    ///
    /// These are used by ``TextEditor``.
    @MainActor
    public protocol TextEditors: TextViews {
        /// Creates an editable multi-line text editor.
        ///
        /// Predominantly used by ``TextEditor``.
        ///
        /// - Returns: A text editor.
        func createTextEditor() -> Widget

        /// Sets the placeholder label and change handler of an editable multi-line
        /// text editor.
        ///
        /// The backend shouldn't wait until the user finishes typing to call the
        /// change handler; it should allow live access to the value.
        ///
        /// - Parameters:
        ///   - textEditor: The text editor to update.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the text editor's content
        ///     changes. This replaces any existing change handlers, and is called
        ///     whenever the displayed value changes.
        func updateTextEditor(
            _ textEditor: Widget,
            environment: EnvironmentValues,
            onChange: @escaping (String) -> Void
        )

        /// Sets the value of an editable multi-line text editor.
        ///
        /// - Parameters:
        ///   - textEditor: The text editor to set the content of.
        ///   - content: The new content.
        func setContent(ofTextEditor textEditor: Widget, to content: String)

        /// Gets the value of an editable multi-line text editor.
        ///
        /// - Parameter textEditor: The text editor to get the content of.
        /// - Returns: `textEditor`'s content.
        func getContent(ofTextEditor textEditor: Widget) -> String
    }
}
