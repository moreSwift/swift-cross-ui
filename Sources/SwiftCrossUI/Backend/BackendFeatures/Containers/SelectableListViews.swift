extension BackendFeatures {
    /// Backend methods for list views that allow selecting items.
    ///
    /// These are used by ``List``.
    @MainActor
    public protocol SelectableListViews: Core {
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
}
