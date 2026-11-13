extension View {
    /// Hides separate labels of any controls contained within this view.
    public func labelsHidden(_ hidden: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.labelsHidden, hidden)
        }
    }
}
