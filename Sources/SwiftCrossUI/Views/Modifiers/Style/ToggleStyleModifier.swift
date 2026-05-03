extension View {
    /// Sets the style of toggles contained within this view.
    ///
    /// - Parameter toggleStyle: The new toggle style.
    public func toggleStyle(_ toggleStyle: ToggleStyle) -> some View {
        return EnvironmentModifier(self) { environment in
            return environment.with(\.toggleStyle, toggleStyle)
        }
    }
}
