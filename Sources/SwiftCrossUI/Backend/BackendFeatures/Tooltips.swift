extension BackendFeatures {
    /// Backend methods for tooltips.
    ///
    /// These are used by ``View/help(_:)``.
    @MainActor
    public protocol Tooltips: Core {
        /// Create a container capable of showing a textual tooltip.
        ///
        /// If no container is necessary, this method is allowed to return `child`
        /// unmodified.
        ///
        /// - Parameters:
        ///   - child: The widget being wrapped to show a tooltip over.
        func createTooltipContainer(wrapping child: Widget) -> Widget

        /// Update the tooltip shown by a widget.
        ///
        /// - Parameters:
        ///   - widget: The widget to update the tooltip for. Will always have been
        ///     created by ``createTooltipContainer(wrapping:)``.
        ///   - tooltip: The text to be shown on hover.
        func updateTooltipContainer(_ widget: Widget, tooltip: String)
    }
}
