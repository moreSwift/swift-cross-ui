extension View {
    /// Modifies this view by binding its focus state to the given state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `nil` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused<Value: Hashable>(
        _ focusBinding: FocusState<Value?>.Binding,
        equals match: Value
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.widgetFocusObservers,
                environment.widgetFocusObservers + [
                    WidgetFocusObserver(
                        didGainFocus: {
                            focusBinding.wrappedValue = match
                        },
                        didLoseFocus: {
                            focusBinding.reset()
                        }
                    )
                ]
            )
            .with(
                \.focusOverride,
                environment.focusOverride.modify(
                    with: focusBinding.wrappedValue,
                    match: match
                )
            )
        }
    }

    /// Modifies this view by binding its focus state to the given Boolean state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `false` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused(
        _ focusBinding: FocusState<Bool>.Binding
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.widgetFocusObservers,
                environment.widgetFocusObservers + [
                    WidgetFocusObserver(
                        didGainFocus: {
                            focusBinding.wrappedValue = true
                        },
                        didLoseFocus: {
                            focusBinding.reset()
                        }
                    )
                ]
            )
            .with(
                \.focusOverride,
                environment.focusOverride != .focused
                    ? focusBinding.wrappedValue ? .focused : .unfocused
                    :.focused
            )
        }
    }
}
