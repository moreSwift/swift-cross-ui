extension View {
    /// Sets the detents (heights) for the enclosing sheet presentation to snap
    /// to when the user resizes it interactively.
    ///
    /// Detents are only respected on platforms that support sheet resizing,
    /// and sheet resizing is generally only supported on mobile.
    ///
    /// If no detents are specified, then a single default detent is used. The
    /// default is platform-specific. On iOS the default is
    /// ``PresentationDetent/large``.
    ///
    /// - Supported platforms: iOS & Mac Catalyst 15+ (ignored on unsupported
    ///   platforms)
    /// - ``PresentationDetent/fraction(_:)`` and
    ///   ``PresentationDetent/height(_:)`` fall back to
    ///   ``PresentationDetent/medium`` on iOS 15 and earlier
    ///
    /// - Parameter detents: A set of detents that the sheet can be resized to.
    /// - Returns: A view with the ``PreferenceValues/presentationDetents``
    ///   preference set.
    public func presentationDetents(_ detents: Set<PresentationDetent>) -> some View {
        preference(key: \.presentationDetents, value: Array(detents))
    }

    /// Sets the corner radius for the enclosing sheet presentation.
    ///
    /// - Supported platforms: iOS & Mac Catalyst 15+, Gtk4 (ignored on
    ///   unsupported platforms)
    ///
    /// - Parameter radius: The corner radius in points.
    /// - Returns: A view with the ``PreferenceValues/presentationCornerRadius``
    ///   preference set.
    public func presentationCornerRadius(_ radius: Double) -> some View {
        preference(key: \.presentationCornerRadius, value: radius)
    }

    /// Sets the visibility of the enclosing sheet presentation's drag
    /// indicator.
    ///
    /// Drag indicators are only supported on platforms that support sheet
    /// resizing, and sheet resizing is generally only supported on mobile.
    ///
    /// - Supported platforms: iOS & Mac Catalyst 15+ (ignored on unsupported
    ///   platforms)
    ///
    /// - Parameter visibility: The visibility to use for the drag indicator of
    ///   the enclosing sheet.
    /// - Returns: A view with the
    ///   ``PreferenceValues/presentationDragIndicatorVisibility`` preference
    ///   set.
    public func presentationDragIndicatorVisibility(
        _ visibility: Visibility
    ) -> some View {
        preference(key: \.presentationDragIndicatorVisibility, value: visibility)
    }

    /// Sets the background of the enclosing sheet presentation.
    ///
    /// - Parameter color: The background color to use for the enclosing sheet
    ///   presentation.
    /// - Returns: A view with the ``PreferenceValues/presentationBackground``
    ///   preference set.
    public func presentationBackground(_ color: Color) -> some View {
        preference(key: \.presentationBackground, value: color)
    }

    /// Prevents the user from dismissing the enclosing sheet presentation.
    ///
    /// When interactive dismissal is disabled, users can only dismiss sheets by
    /// performing actions that your code handles and turns into programmatic
    /// dismissals.
    ///
    /// - Parameter isDisabled: Whether interactive dismissal is disabled.
    /// - Returns: A view with the
    ///   ``PreferenceValues/interactiveDismissDisabled`` preference set.
    public func interactiveDismissDisabled(_ isDisabled: Bool = true) -> some View {
        preference(key: \.interactiveDismissDisabled, value: isDisabled)
    }

    /// Sets the preferred color scheme for the nearest enclosing presentation,
    /// such as a sheet or window.
    ///
    /// > Note: Not supported by GtkBackend or Gtk3Backend. When targeting those
    /// > platforms this modifier has no effect.
    ///
    /// - Parameter colorScheme: The preferred color scheme for the nearest
    ///   enclosing presentation.
    /// - Returns: A view with the ``PreferenceValues/preferredColorScheme``
    ///   preference set.
    public func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
        preference(key: \.preferredColorScheme, value: colorScheme)
    }
}
