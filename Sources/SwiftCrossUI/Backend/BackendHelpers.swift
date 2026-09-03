enum BackendHelpers {
    /// Sets the ``WidgetFocusObserver``s from the environment on a widget.
    static func setWidgetFocusObservers<Backend: BackendFeatures.Focus>(
        of widget: AnyWidget,
        with backend: Backend,
        environment: EnvironmentValues
    ) {
        backend.registerFocusObservers(
            environment.widgetFocusObservers,
            on: widget.into()
        )

        backend.setFocusEffectDisabled(
            on: widget.into(),
            disabled: environment.focusEffectDisabled
        )
    }

    /// Makes a widget gain or lose focus.
    static func setFocus<Backend: BackendFeatures.Focus>(
        of widget: AnyWidget,
        to focus: Focus?,
        with backend: Backend
    ) {
        guard let focus else { return }
        backend.setFocus(of: widget.into(), to: focus)
    }
}
