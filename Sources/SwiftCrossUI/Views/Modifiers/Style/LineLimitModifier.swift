extension View {
    /// Sets a limit for the number of lines text can occupy in this view.
    public func lineLimit(_ limit: Int?, reservesSpace: Bool = false) -> some View {
        EnvironmentModifier(self) { environment in
            if let limit {
                environment
                    .with(
                        \.lineLimitSettings, LineLimit(limit: limit, reservesSpace: reservesSpace))
            } else {
                environment.with(\.lineLimitSettings, nil)
            }
        }
    }
}
