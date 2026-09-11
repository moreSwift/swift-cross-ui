import AppKit

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
