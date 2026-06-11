import AppKit
import SwiftCrossUI

// MARK: ScrollContainers
extension AppKitBackend {
    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = NSScrollView()

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
        documentView.heightAnchor.constraint(greaterThanOrEqualTo: clipView.heightAnchor)
            .isActive = true
        documentView.widthAnchor.constraint(greaterThanOrEqualTo: clipView.widthAnchor)
            .isActive = true

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
        let scrollView = scrollView as! NSScrollView
        scrollView.hasVerticalScroller = hasVerticalScrollBar
        scrollView.hasHorizontalScroller = hasHorizontalScrollBar
        scrollView.verticalScrollElasticity = bounceVertically ? .allowed : .none
        scrollView.horizontalScrollElasticity = bounceHorizontally ? .allowed : .none
    }
}

// MARK: SelectableListViews
extension AppKitBackend {
    public func createSelectableListView() -> Widget {
        let scrollView = NSDisabledScrollView()
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false

        let listView = NSCustomTableView()
        listView.delegate = listView.customDelegate
        listView.dataSource = listView.customDelegate
        listView.allowsColumnSelection = false
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("list-column"))
        listView.customDelegate.columnCount = 1
        listView.customDelegate.columnIndices = [
            ObjectIdentifier(column): 0
        ]
        listView.customDelegate.allowSelections = true
        listView.backgroundColor = .clear
        listView.headerView = nil
        listView.addTableColumn(column)
        if #available(macOS 11.0, *) {
            listView.style = .plain
        }

        scrollView.documentView = listView
        listView.enclosingScrollView?.drawsBackground = false
        return scrollView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        let scrollView = selectableListView as! NSDisabledScrollView
        let listView = scrollView.documentView! as! NSCustomTableView
        listView.isEnabled = environment.isEnabled
    }

    public func baseItemPadding(
        ofSelectableListView listView: Widget
    ) -> SwiftCrossUI.EdgeInsets {
        // TODO: Figure out if there's a way to compute this more directly. At
        //   the moment these are just figures from empirical observations.
        SwiftCrossUI.EdgeInsets(top: 0, bottom: 0, leading: 8, trailing: 8)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView
        listView.customDelegate.rowCount = items.count
        listView.customDelegate.widgets = items
        listView.customDelegate.rowHeights = rowHeights
        listView.reloadData()
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView
        listView.customDelegate.selectionHandler = action
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView
        listView.selectRowIndexes(IndexSet([index].compactMap { $0 }), byExtendingSelection: false)
    }
}

/// A scroll view with scrolling gestures disabled. Used as a dummy scroll view to
/// allow us to properly set the width of NSTableView (had some weird issues).
final class NSDisabledScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        self.nextResponder?.scrollWheel(with: event)
    }
}

// MARK: SplitViews
extension AppKitBackend {
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

class NSCustomSplitView: NSSplitView {
    var resizingDelegate: NSSplitViewResizingDelegate?
}

class NSSplitViewResizingDelegate: NSObject, NSSplitViewDelegate {
    var resizeHandler: (() -> Void)?
    var leadingWidth = 0
    var minimumLeadingWidth = 0
    var maximumLeadingWidth = 0
    var isFirstUpdate = true
    /// Tracks whether AppKit is resizing the side bar (as opposed to the user resizing it).
    var appKitIsResizing = false

    func setResizeHandler(_ handler: @escaping () -> Void) {
        resizeHandler = handler
    }

    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        appKitIsResizing = true
        return true
    }

    func splitViewDidResizeSubviews(_ notification: Notification) {
        appKitIsResizing = false
        let splitView = notification.object! as! NSSplitView
        let paneWidths = splitView.subviews.map(\.frame.width).map { width in
            Int(width.rounded())
        }
        let previousWidth = leadingWidth
        leadingWidth = paneWidths[0]

        // Only call the handler if the side bar has actually changed size.
        if leadingWidth != previousWidth {
            resizeHandler?()
        }
    }

    func splitView(
        _ splitView: NSSplitView,
        constrainMinCoordinate proposedMinimumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if dividerIndex == 0 {
            return CGFloat(minimumLeadingWidth)
        } else {
            return proposedMinimumPosition
        }
    }

    func splitView(
        _ splitView: NSSplitView,
        constrainMaxCoordinate proposedMaximumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if dividerIndex == 0 {
            return CGFloat(maximumLeadingWidth)
        } else {
            return proposedMaximumPosition
        }
    }

    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        splitView.adjustSubviews()

        if isFirstUpdate {
            splitView.setPosition(max(200, CGFloat(minimumLeadingWidth)), ofDividerAt: 0)
            isFirstUpdate = false
        } else {
            let newWidth = splitView.subviews[0].frame.width
            // If AppKit is trying to automatically resize our side bar (e.g. because the split
            // view has changed size), only let it do so if not doing so would put out side bar
            // outside of the allowed bounds.
            if appKitIsResizing
                && leadingWidth >= minimumLeadingWidth
                && leadingWidth <= maximumLeadingWidth
            {
                splitView.setPosition(CGFloat(leadingWidth), ofDividerAt: 0)
            } else {
                // Magic! Thanks https://stackoverflow.com/a/30494691. This one line fixed all
                // of the split view resizing issues.
                splitView.setPosition(newWidth, ofDividerAt: 0)
            }
        }
    }
}
