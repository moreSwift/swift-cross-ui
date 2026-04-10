import Foundation

extension AppBackend {
    /// Backend methods for widget containers.
    ///
    /// These protocols let apps implement views that wrap widgets within
    /// other widgets, such as scroll views or split views.
    ///
    /// The "generic" container is implemented separately from this;
    /// see ``GenericContainers`` for more details on that protocol.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``ScrollContainer``
    /// - ``SelectableListView``
    /// - ``SplitView``
    /// - ``Tables``
    public typealias Containers =
        ScrollContainer & SelectableListView & SplitView & Tables

    /// Backend methods for scroll containers.
    ///
    /// These are used by ``ScrollView`` and other views that require scrolling.
    @MainActor
    public protocol ScrollContainer: Core {
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

    /// Backend methods for list views that allow selecting items.
    ///
    /// These are used by ``List``.
    @MainActor
    public protocol SelectableListView: Core {
        /// Creates a list with selectable rows.
        ///
        /// - Returns: A list with selectable rows.
        func createSelectableListView() -> Widget

        /// Updates a list with the current environment. Should update list view to
        /// respect ``EnvironmentValues/isEnabled``.
        func updateSelectableListView(
            _ selectableListView: Widget,
            environment: EnvironmentValues
        )

        /// Gets the amount of padding introduced by the backend around the content of
        /// each row.
        ///
        /// Ideally backends should get rid of base padding so that SwiftCrossUI can
        /// give developers more freedom, but this isn't always possible.
        ///
        /// - Parameter listView: The list view.
        /// - Returns: An `EdgeInsets` instance describing the amount of base
        ///   padding around `listView`'s items.
        func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets

        /// Gets the minimum size for rows in the list view.
        ///
        /// This doesn't necessarily have to be just for hard requirements enforced
        /// by the backend, it can also just be an idiomatic minimum size for the
        /// platform.
        ///
        /// - Parameter listView: The list view.
        /// - Returns: The minimum size for rows in the list view.
        func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int>

        /// Sets the items of a selectable list along with their heights.
        ///
        /// Row heights should include base item padding (i.e. they should be the
        /// external height of the row rather than the internal height).
        ///
        /// - Parameters:
        ///   - listView: The list view.
        ///   - items: An array of widgets to add to `listView`.
        ///   - rowHeights: The row heights of `items`.
        func setItems(
            ofSelectableListView listView: Widget,
            to items: [Widget],
            withRowHeights rowHeights: [Int]
        )

        /// Sets the action to perform when a user selects an item in the list.
        ///
        /// - Parameters:
        ///   - listView: The list view.
        ///   - action: The selection handler. Receives the selected item's index.
        func setSelectionHandler(
            forSelectableListView listView: Widget,
            to action: @escaping (_ selectedIndex: Int) -> Void
        )

        /// Sets the list's selected item by index.
        ///
        /// - Parameters:
        ///   - listView: The list view.
        ///   - index: The index of the item to select.
        func setSelectedItem(
            ofSelectableListView listView: Widget,
            toItemAt index: Int?
        )
    }

    /// Backend methods for split views.
    ///
    /// These are used by ``NavigationSplitView`` and sidebar-style ``List``s.
    @MainActor
    public protocol SplitView: Core {
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

    /// Backend methods for tables.
    ///
    /// These are used by ``Table``.
    @MainActor
    public protocol Tables: Core {
        /// The default height of a table row excluding cell padding. This is a
        /// recommendation by the backend that SwiftCrossUI won't necessarily
        /// follow in all cases.
        var defaultTableRowContentHeight: Int { get }

        /// The default vertical padding to apply to table cells.
        ///
        /// This is the amount of padding added above and below each cell, not the
        /// total amount added along the vertical axis. It's a recommendation by the
        /// backend that SwiftCrossUI won't necessarily follow in all cases.
        var defaultTableCellVerticalPadding: Int { get }

        /// Creates an empty table.
        ///
        /// - Returns: A table.
        func createTable() -> Widget

        /// Sets the number of rows of a table.
        ///
        /// Existing rows outside of the new bounds should be deleted.
        ///
        /// - Parameters:
        ///   - table: The table to set the row count of.
        ///   - rows: The number of rows.
        func setRowCount(ofTable table: Widget, to rows: Int)

        /// Sets the labels of a table's columns. Also sets the number of columns of
        /// the table to the number of labels provided.
        ///
        /// - Parameters:
        ///   - table: The table to set the column labels of.
        ///   - labels: The column labels to set.
        ///   - environment: The current environment.
        func setColumnLabels(
            ofTable table: Widget,
            to labels: [String],
            environment: EnvironmentValues
        )

        /// Sets the contents of the table as a flat array of cells in order of and
        /// grouped by row. Also sets the height of each row's content.
        ///
        /// A nested array would have significantly more overhead, especially for
        /// large arrays.
        ///
        /// - Parameters:
        ///   - table: The table.
        ///   - cells: The widgets to fill the table with.
        ///   - rowHeights: The heights of the table's rows.
        func setCells(
            ofTable table: Widget,
            to cells: [Widget],
            withRowHeights rowHeights: [Int]
        )
    }
}
