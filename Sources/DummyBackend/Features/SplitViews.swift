@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.SplitViews {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        SplitView(
            leadingChild: leadingChild,
            trailingChild: trailingChild
        )
    }

    public func setResizeHandler(ofSplitView splitView: Widget, to action: @escaping () -> Void) {
        (splitView as! SplitView).sidebarResizeHandler = action
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        (splitView as! SplitView).sidebarWidth
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! SplitView
        splitView.minimumSidebarWidth = minimumWidth
        splitView.maximumSidebarWidth = maximumWidth
    }
}
