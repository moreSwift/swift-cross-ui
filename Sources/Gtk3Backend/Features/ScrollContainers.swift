import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ScrollContainers {
    public var scrollBarWidth: Int { 0 }

    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = ScrolledWindow()
        scrollView.add(child)
        return scrollView
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        let scrollView = scrollView as! ScrolledWindow
        scrollView.setScrollBarPresence(
            hasVerticalScrollBar: hasVerticalScrollBar,
            hasHorizontalScrollBar: hasHorizontalScrollBar
        )
    }
}
