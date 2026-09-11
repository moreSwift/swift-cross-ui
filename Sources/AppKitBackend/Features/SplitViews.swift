import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.SplitViews {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        let splitView = NSCustomSplitView()
        let leadingChildWithEffect = NSVisualEffectView()
        leadingChildWithEffect.blendingMode = .behindWindow
        leadingChildWithEffect.material = .sidebar
        leadingChildWithEffect.addSubview(leadingChild)
        leadingChild.widthAnchor.constraint(equalTo: leadingChildWithEffect.widthAnchor)
            .isActive = true
        leadingChild.heightAnchor.constraint(equalTo: leadingChildWithEffect.heightAnchor)
            .isActive = true
        leadingChild.topAnchor.constraint(equalTo: leadingChildWithEffect.topAnchor)
            .isActive = true
        leadingChild.leadingAnchor.constraint(equalTo: leadingChildWithEffect.leadingAnchor)
            .isActive = true
        leadingChild.translatesAutoresizingMaskIntoConstraints = false
        leadingChildWithEffect.translatesAutoresizingMaskIntoConstraints = false

        splitView.addArrangedSubview(leadingChildWithEffect)
        splitView.addArrangedSubview(trailingChild)
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        let defaultLeadingWidth = 200
        splitView.setPosition(CGFloat(defaultLeadingWidth), ofDividerAt: 0)
        splitView.adjustSubviews()

        let delegate = NSSplitViewResizingDelegate()
        delegate.leadingWidth = defaultLeadingWidth
        splitView.delegate = delegate
        splitView.resizingDelegate = delegate
        return splitView
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        let splitView = splitView as! NSCustomSplitView
        splitView.resizingDelegate?.setResizeHandler {
            action()
        }
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        let splitView = splitView as! NSCustomSplitView
        return splitView.resizingDelegate!.leadingWidth
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! NSCustomSplitView
        splitView.resizingDelegate!.minimumLeadingWidth = minimumWidth
        splitView.resizingDelegate!.maximumLeadingWidth = maximumWidth
    }
}
