@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.SplitViews {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        let splitView = CustomSplitView()
        splitView.pane = leadingChild
        splitView.content = trailingChild
        splitView.isPaneOpen = true
        splitView.displayMode = .inline
        return splitView
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        // WinUI's SplitView currently doesn't support resizing, but we still
        // store the sidebar resize handler because we programmatically resize
        // the sidebar and call the handler whenever the minimum sidebar width
        // changes.
        let splitView = splitView as! CustomSplitView
        splitView.sidebarResizeHandler = action
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        let splitView = splitView as! CustomSplitView
        return Int(splitView.openPaneLength.rounded(.towardZero))
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! CustomSplitView
        let newWidth = Double(max(minimumWidth, 10))
        if newWidth != splitView.openPaneLength {
            splitView.openPaneLength = newWidth
            splitView.sidebarResizeHandler?()
        }
    }

    public func visibleColumns(
        ofSplitView splitView: Widget
    ) -> Set<NavigationSplitViewColumn> {
        return [.sidebar, .detail]
    }

    public func showColumn(
        _ column: NavigationSplitViewColumn,
        ofSplitView splitView: Widget
    ) {
        // We don't hide columns yet, so we can implement this trivially :)
    }

    public func internalPadding(
        ofSplitView splitView: Widget,
        column: NavigationSplitViewColumn
    ) -> SIMD2<Int> {
        .zero
    }

    public func setColumnVisibilityChangeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping (NavigationSplitViewColumn, Bool) -> Void
    ) {
        // TODO(stackotter): Handle toggling sidebar visibility
    }
}
