@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.ScrollContainers {
    public var scrollBarWidth: Int { 8 }

    public func createScrollContainer(for child: Widget) -> Widget {
        ScrollContainer(child: child)
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        let scrollContainer = scrollView as! ScrollContainer
        scrollContainer.hasVerticalScrollBar = hasVerticalScrollBar
        scrollContainer.hasHorizontalScrollBar = hasHorizontalScrollBar
        scrollContainer.bouncesHorizontally = bounceHorizontally
        scrollContainer.bouncesVertically = bounceVertically
    }
}
