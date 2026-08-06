extension View {
    /// Assigns a keyboard shortcut to this view.
    ///
    /// - Parameter shortcut: The keyboard shortcut to assign.
    public func keyboardShortcut(_ shortcut: KeyboardShortcut) -> some View {
        environment(\.keyboardShortcut, shortcut)
    }

    /// Assigns a keyboard shortcut to this view.
    ///
    /// - Parameters:
    ///   - key: The key equivalent for this shortcut.
    ///   - modifiers: Modifier keys for this shortcut.
    public func keyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .primary
    ) -> some View {
        environment(
            \.keyboardShortcut,
             KeyboardShortcut(key, modifiers: modifiers)
        )
    }
}
