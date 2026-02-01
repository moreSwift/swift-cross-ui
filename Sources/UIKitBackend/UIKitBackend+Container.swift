import SwiftCrossUI
import UIKit

final class ScrollWidget: ContainerWidget {
    var scrollView = UIScrollView()
    private var childWidthConstraint: NSLayoutConstraint?
    private var childHeightConstraint: NSLayoutConstraint?

    private lazy var contentLayoutGuideConstraints: [NSLayoutConstraint] = [
        scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
        scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
        scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: child.view.topAnchor),
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: child.view.bottomAnchor),
    ]

    override func loadView() {
        view = scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func updateViewConstraints() {
        NSLayoutConstraint.activate(contentLayoutGuideConstraints)
        super.updateViewConstraints()
    }

    func setScrollBars(
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        switch (hasVerticalScrollBar, childHeightConstraint?.isActive) {
            case (true, true):
                childHeightConstraint!.isActive = false
            case (false, nil):
                childHeightConstraint = child.view.heightAnchor.constraint(
                    equalTo: scrollView.heightAnchor)
                fallthrough
            case (false, false):
                childHeightConstraint!.isActive = true
            default:
                break
        }

        switch (hasHorizontalScrollBar, childWidthConstraint?.isActive) {
            case (true, true):
                childWidthConstraint!.isActive = false
            case (false, nil):
                childWidthConstraint = child.view.widthAnchor.constraint(
                    equalTo: scrollView.widthAnchor)
                fallthrough
            case (false, false):
                childWidthConstraint!.isActive = true
            default:
                break
        }

        scrollView.showsVerticalScrollIndicator = hasVerticalScrollBar
        scrollView.showsHorizontalScrollIndicator = hasHorizontalScrollBar
    }

    public func updateScrollContainer(environment: EnvironmentValues) {
        #if os(iOS)
            scrollView.keyboardDismissMode =
                switch environment.scrollDismissesKeyboardMode {
                    case .automatic:
                        .interactive
                    case .immediately:
                        .onDrag
                    case .interactively:
                        .interactive
                    case .never:
                        .none
                }
        #endif
    }
}

extension UIKitBackend {
    public func createContainer() -> Widget {
        BaseViewWidget()
    }

    public func removeAllChildren(of container: Widget) {
        container.childWidgets.forEach { $0.removeFromParentWidget() }
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        (container as! BaseViewWidget).insert(child, at: index)
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        container.view.exchangeSubview(at: firstIndex, withSubviewAt: secondIndex)
        container.childWidgets.swapAt(firstIndex, secondIndex)
    }

    public func setPosition(
        ofChildAt index: Int,
        in container: Widget,
        to position: SIMD2<Int>
    ) {
        guard index < container.childWidgets.count else {
            assertionFailure("Attempting to set position of nonexistent subview")
            return
        }

        let child = container.childWidgets[index]
        child.x = position.x
        child.y = position.y
    }

    public func remove(childAt index: Int, from container: Widget) {
        container.childWidgets[index].removeFromParentWidget()
    }

    public func createColorableRectangle() -> Widget {
        BaseViewWidget()
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        widget.view.backgroundColor = color.uiColor
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.view.layer.cornerRadius = CGFloat(radius)
        widget.view.layer.masksToBounds = true
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        let size = widget.view.intrinsicContentSize
        return SIMD2(
            Int(size.width.rounded(.awayFromZero)),
            Int(size.height.rounded(.awayFromZero))
        )
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.width = size.x
        widget.height = size.y
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        ScrollWidget(child: child)
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {
        let scrollViewWidget = scrollView as! ScrollWidget
        scrollViewWidget.updateScrollContainer(environment: environment)
    }

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        let scrollWidget = scrollView as! ScrollWidget
        scrollWidget.setScrollBars(
            hasVerticalScrollBar: hasVerticalScrollBar,
            hasHorizontalScrollBar: hasHorizontalScrollBar)
    }
}
