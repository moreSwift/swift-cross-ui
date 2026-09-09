extension View {
    /// Conditionally disables the focus indicator.
    public func focusEffectDisabled(_ disabled: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.focusEffectDisabled, disabled)
        }
    }
}
