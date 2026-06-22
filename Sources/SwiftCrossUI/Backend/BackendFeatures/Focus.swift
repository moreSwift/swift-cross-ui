extension BackendFeatures {
    /// Backend methods for handling focus.
    ///
    /// These are used by
    /// ``View/focused(_:)``
    /// ``View/focused(_:equals:)``
    /// ``View/focusEffectDisabled(_:)``
    public protocol Focus: Core {
        /// Register a ``FocusState`` on the widget.
        ///
        /// Used to both focus a `Widget` programmatically and update the ``FocusState``
        /// when focused is gained/lost through user interaction.
        ///
        /// Called by ``ViewGraphNode/commit()`` and `_BuiltinPickerImplementation/commit`.
        func registerFocusObservers(
            _ data: [FocusData],
            on widget: Widget
        )

        /// Controls the focus effect of a widget.
        ///
        /// Used by ``View/focusable(_:)``.
        func setFocusEffectDisabled(on widget: Widget, disabled: Bool)
    }

    /// Backend methods for disabling focusability of a subtree.
    ///
    /// Used by ``View/focusable(_:)``.
    public protocol FocusDisabling: Core {
        /// Create a container controlling the focusability of the widgets below it.
        ///
        /// Used by ``View/focusable(_:)``.
        func createFocusContainer() -> Widget

        /// Update a container controlling the focusability of the widgets below it.
        ///
        /// Used by ``View/focusable(_:)``.
        func updateFocusContainer(
            _ widget: Widget,
            focusability: Focusability
        )
    }
}
