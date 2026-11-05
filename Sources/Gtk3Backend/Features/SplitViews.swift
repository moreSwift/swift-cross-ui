import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.SplitViews {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        let widget = Paned(orientation: .horizontal)

        let leadingContainer = CustomRootWidget()
        leadingContainer.setChild(to: leadingChild)
        widget.startChild = leadingContainer

        let trailingContainer = CustomRootWidget()
        trailingContainer.setChild(to: trailingChild)
        widget.endChild = trailingContainer

        widget.position = 200
        return widget
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        let splitView = splitView as! Paned
        splitView.notifyPosition = { _ in
            action()
        }
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        let splitView = splitView as! Paned
        return splitView.position
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! Paned
        show(widget: splitView.startChild!)
        let width = splitView.getNaturalSize().width
        splitView.startChild?.setSizeRequest(width: minimumWidth, height: 0)
        splitView.endChild?.setSizeRequest(width: width - maximumWidth, height: 0)
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
