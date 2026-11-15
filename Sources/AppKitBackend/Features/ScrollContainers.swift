import AppKit
@_spi(Backends) import SwiftCrossUI

final class CustomScrollView: NSScrollView {
    lazy var verticalScrollingConstraint = documentView!.heightAnchor.constraint(greaterThanOrEqualTo: contentView.heightAnchor)
    lazy var verticalNonScrollingConstraint = documentView!.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor)
    lazy var horizontalScrollingConstraint = documentView!.widthAnchor.constraint(greaterThanOrEqualTo: contentView.widthAnchor)
    lazy var horizontalNonScrollingConstraint = documentView!.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor)
}

extension AppKitBackend: BackendFeatures.ScrollContainers {
    public var scrollBarWidth: Int {
        // We assume that all scrollers have their controlSize set to `.regular` by default.
        // The internet seems to indicate that this is true regardless of any system wide
        // preferences etc.
        if NSScroller.preferredScrollerStyle == .overlay {
            0
        } else {
            Int(
                NSScroller.scrollerWidth(
                    for: .regular,
                    scrollerStyle: NSScroller.preferredScrollerStyle
                ).rounded(.awayFromZero)
            )
        }
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = CustomScrollView()

        let clipView = scrollView.contentView
        let documentView = NSStackView()
        documentView.orientation = .vertical
        documentView.alignment = .leading
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.addView(child, in: .top)
        scrollView.documentView = documentView

        scrollView.drawsBackground = false

        documentView.topAnchor.constraint(equalTo: clipView.topAnchor).isActive = true
        documentView.leftAnchor.constraint(equalTo: clipView.leftAnchor).isActive = true

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
        let scrollView = scrollView as! CustomScrollView
        scrollView.hasVerticalScroller = hasVerticalScrollBar
        scrollView.hasHorizontalScroller = hasHorizontalScrollBar
        scrollView.verticalScrollElasticity = bounceVertically ? .allowed : .none
        scrollView.horizontalScrollElasticity = bounceHorizontally ? .allowed : .none
        scrollView.verticalScrollingConstraint.isActive = hasVerticalScrollBar
        scrollView.verticalNonScrollingConstraint.isActive = !hasVerticalScrollBar
        scrollView.horizontalScrollingConstraint.isActive = hasHorizontalScrollBar
        scrollView.horizontalNonScrollingConstraint.isActive = !hasHorizontalScrollBar
    }
}
