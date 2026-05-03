extension View {
    /// Adds an action to perform when the user submits a text field within this
    /// view (generally via pressing the Enter/Return key). Outer `onSubmit`
    /// handlers get called before inner `onSubmit` handlers. To prevent
    /// submissions from propagating upwards, use ``View/submitScope()`` after
    /// adding the handler.
    ///
    /// - Parameter action: The action to perform.
    public func onSubmit(perform action: @escaping () -> Void) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.onSubmit) {
                environment.onSubmit?()
                action()
            }
        }
    }

    /// Prevents text field submissions from propagating to this view's
    /// ancestors.
    public func submitScope() -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.onSubmit, nil)
        }
    }
}
