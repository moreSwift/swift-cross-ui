extension View {
    /// Configures the behavior in which scrollable content interacts with the
    /// software keyboard.
    ///
    /// You use this modifier to customize how scrollable content interacts with
    /// the software keyboard. For example, you can specify a value of
    /// ``ScrollDismissesKeyboardMode/immediately`` to indicate that you would
    /// like scrollable content to immediately dismiss the keyboard if present
    /// when a scroll drag gesture begins.
    ///
    ///     @State private var text = ""
    ///
    ///     ScrollView {
    ///         TextField("Prompt", text: $text)
    ///         ForEach(0 ..< 50) { index in
    ///             Text("\(index)")
    ///                 .padding()
    ///         }
    ///     }
    ///     .scrollDismissesKeyboard(.immediately)
    ///
    /// You can also use this modifier to customize the keyboard dismissal
    /// behavior for other kinds of scrollable views, like a ``List`` or a
    /// ``TextEditor``.
    ///
    /// By default, scrollable content dismisses the keyboard interactively as
    /// the user scrolls. Pass a different value of
    /// ``ScrollDismissesKeyboardMode`` to change this behavior. For example,
    /// use ``ScrollDismissesKeyboardMode/never`` to prevent the keyboard from
    /// dismissing automatically. Note that ``TextEditor`` may still use a
    /// different default to preserve expected editing behavior.
    ///
    /// - Parameter mode: The keyboard dismissal mode that scrollable content
    ///   uses.
    ///
    /// - Returns: A view that uses the specified keyboard dismissal mode.
    public func scrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardMode) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.scrollDismissesKeyboardMode, mode)
        }
    }
}
