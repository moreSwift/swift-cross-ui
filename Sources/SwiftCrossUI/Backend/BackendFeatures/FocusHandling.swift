extension BackendFeatures {
    /// Backend methods for handling focus.
    ///
    /// These are used by
    /// ``View/focused(_:)``
    /// ``View/focused(_:equals:)``
    /// ``View/focusEffectDisabled(_:)``
    @MainActor
    public protocol FocusHandling: Core {
        /// Register a ``FocusState`` on the widget.
        ///
        /// Used to both focus a `Widget` programmatically and update the ``FocusState``
        /// when focused is gained/lost through user interaction.
        ///
        /// Called by ``ViewGraphNode/commit()`` and `_BuiltinPickerImplementation/commit`.
        func registerFocusObservers(
            _ data: [WidgetFocusObserver],
            on widget: Widget
        )

        /// Controls the focus effect of a widget.
        ///
        /// Used by ``View/focusable(_:)``.
        func setFocusEffectDisabled(on widget: Widget, disabled: Bool)

        /// Makes a widget gain or lose focus.
        func setFocus(of widget: Widget, to focus: SwiftCrossUI.Focus)
    }

    /// Backend methods for disabling focusability of a subtree.
    ///
    /// Used by ``View/focusable(_:)``.
    @MainActor
    public protocol FocusDisabling: Core {
        /// Create a container controlling the focusability of its children.
        ///
        /// Used by ``View/focusable(_:)``.
        func createFocusContainer() -> Widget

        /// Update a container controlling the focusability of its children.
        ///
        /// Used by ``View/focusable(_:)``.
        func updateFocusContainer(
            _ widget: Widget,
            focusability: Focusability
        )
    }
}
