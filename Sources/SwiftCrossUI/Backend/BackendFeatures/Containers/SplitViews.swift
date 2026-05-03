extension BackendFeatures {
    /// Backend methods for split views.
    ///
    /// These are used by ``NavigationSplitView`` and sidebar-style ``List``s.
    @MainActor
    public protocol SplitViews: Core {
        /// Creates a split view containing two children visible side by side.
        ///
        /// If you need to modify the leading and trailing children after creation,
        /// nest them inside another container such as a ``VStack`` (avoiding update
        /// methods makes maintaining a multitude of backends a bit easier).
        ///
        /// - Parameters:
        ///   - leadingChild: The widget to show in the sidebar.
        ///   - trailingChild: The widget to show in the detail section.
        func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget

        /// Sets the function to be called when the split view's panes get resized.
        ///
        /// - Parameters:
        ///   - splitView: The split view.
        ///   - action: The action to perform when the split view's panes are
        ///     resized.
        func setResizeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping () -> Void
        )

        /// Gets the width of a split view's sidebar.
        ///
        /// - Parameter splitView: The split view.
        /// - Returns: The split view's sidebar width.
        func sidebarWidth(ofSplitView splitView: Widget) -> Int

        /// Sets the minimum and maximum width of a split view's sidebar.
        ///
        /// - Parameters:
        ///   - splitView: The split view.
        ///   - minimumWidth: The minimum width of the split view's sidebar.
        ///   - maximumWidth: The maximum width of the split view's sidebar.
        func setSidebarWidthBounds(
            ofSplitView splitView: Widget,
            minimum minimumWidth: Int,
            maximum maximumWidth: Int
        )
    }
}
