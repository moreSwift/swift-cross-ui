import Foundation

extension AppBackend {
    public typealias Containers =
        ScrollContainer & SelectableListView & SplitView & Tooltips

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

// MARK: Default Implementations

extension AppBackend.ScrollContainer {
    public func createScrollContainer(for child: Widget) -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}

extension AppBackend.SelectableListView {
    public func createSelectableListView() -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}

extension AppBackend.SplitView {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}

extension AppBackend.Tooltips {
    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}
