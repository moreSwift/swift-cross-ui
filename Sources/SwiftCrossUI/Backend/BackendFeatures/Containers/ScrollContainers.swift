extension BackendFeatures {
    /// Backend methods for scroll containers.
    ///
    /// These are used by ``ScrollView`` and other views that require scrolling.
    @MainActor
    public protocol ScrollContainers: Core {
        /// Gets the layout width of a backend's scroll bars.
        ///
        /// Assumes that the width is the same for both vertical and horizontal
        /// scroll bars (where the width of a horizontal scroll bar is what pedants
        /// may call its height). If the backend uses overlay scroll bars then this
        /// width should be 0.
        ///
        /// This value may make sense to have as a computed property for some backends
        /// such as `AppKitBackend` where plugging in a mouse can cause the default
        /// scroll bar style to change. If something does cause this value to change,
        /// ensure that the configured root environment change handler gets called so
        /// that SwiftCrossUI can update the app's layout accordingly.
        var scrollBarWidth: Int { get }

        /// Creates a scrollable single-child container wrapping the given widget.
        ///
        /// - Parameter child: The widget to wrap in a scroll container.
        /// - Returns: A scroll container wrapping `child`.
        func createScrollContainer(for child: Widget) -> Widget

        /// Updates a scroll container with environment-specific values.
        ///
        /// This method is primarily used on iOS to apply environment changes
        /// that affect the scroll view’s behavior, such as keyboard dismissal mode.
        ///
        /// - Parameters:
        ///   - scrollView: The scroll container widget previously created by
        ///     ``createScrollContainer(for:)``.
        ///   - environment: The current ``EnvironmentValues`` to apply.
        ///   - bounceHorizontally: Whether the scroll view should 'bounce' horizontally.
        ///     Some backends ignore this, as it's not a universal concept.
        ///   - bounceVertically: Whether the scroll view should 'bounce' vertically.
        ///     Some backends ignore this, as it's not a universal concept.
        ///   - hasHorizontalScrollBar: Whether the scroll view has a horizontal
        ///     scroll bar.
        ///   - hasVerticalScrollBar: Whether the scroll view has a vertical scroll
        ///     bar.
        func updateScrollContainer(
            _ scrollView: Widget,
            environment: EnvironmentValues,
            bounceHorizontally: Bool,
            bounceVertically: Bool,
            hasHorizontalScrollBar: Bool,
            hasVerticalScrollBar: Bool
        )
    }
}
