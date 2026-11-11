extension View {
    /// Sets the style for buttons within this view to a button style with
    /// a custom appearance and standard interaction behavior.
    public func buttonStyle(_ style: ButtonStyle?) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.buttonStyle, style)
        }
    }
}
