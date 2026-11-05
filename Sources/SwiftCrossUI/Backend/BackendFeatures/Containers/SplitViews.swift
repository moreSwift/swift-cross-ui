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

        /// Gets the visible columns of a split view.
        /// - Parameter splitView: The split view.
        /// - Returns: The split view's visible columns.
        func visibleColumns(ofSplitView splitView: Widget) -> Set<NavigationSplitViewColumn>

        /// Updates a split view's configuration to display the specified column.
        /// - Parameters:
        ///   - column: The column to show.
        ///   - splitView: The split view.
        func showColumn(
            _ column: NavigationSplitViewColumn,
            ofSplitView splitView: Widget
        )

        /// Computes the amount of internal padding taken up by built-in
        /// controls of a split view within the given column. For example, on iOS
        /// in collapsed mode, the split view reserves space at the top of each
        /// column for navigation controls.
        /// - Parameters:
        ///   - splitView: The split view.
        ///   - column: The column to get the internal padding of.
        /// - Returns: The internal padding of the requested column.
        func internalPadding(
            ofSplitView splitView: Widget,
            column: NavigationSplitViewColumn
        ) -> SIMD2<Int>

        /// Sets the function to be called when one of the split view's columns
        /// appears or disappears due to a user interaction (not due to a backend
        /// method call).
        /// - Parameters:
        ///   - splitView: The split view.
        ///   - action: The action to run. The first parameter is the column that
        ///     has changed visibility, and the second parameter represents
        ///     whether the column is visible or not after the change. For example,
        ///     if the column has disappeared then the second parameter would be
        ///     `false`.
        func setColumnVisibilityChangeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping (NavigationSplitViewColumn, Bool) -> Void
        )
    }
}
