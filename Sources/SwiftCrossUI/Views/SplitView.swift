import Foundation

/// A two-column split view.
struct SplitView<Sidebar: View, Detail: View>: TypeSafeView, View {
    typealias Children = SplitViewChildren<EnvironmentModifier<Sidebar>, Detail>

    var body: TupleView2<EnvironmentModifier<Sidebar>, Detail>

    /// Creates a two-column split view.
    ///
    /// - Parameters:
    ///   - sidebar: The sidebar content.
    ///   - detail: The detail content.
    init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
        body = TupleView2(
            EnvironmentModifier(sidebar()) { $0.with(\.listStyle, .sidebar) },
            detail()
        )
    }

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        SplitViewChildren(
            wrapping: body.children(
                backend: backend,
                snapshots: snapshots,
                environment: environment
            ),
            backend: backend
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        return backend.createSplitView(
            leadingChild: children.leadingPaneContainer.into(),
            trailingChild: children.trailingPaneContainer.into()
        )
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let leadingWidth = Double(backend.sidebarWidth(ofSplitView: widget))

        let leadingPanePadding = backend.internalPadding(ofSplitView: widget, column: .sidebar)
        let trailingPanePadding = backend.internalPadding(ofSplitView: widget, column: .detail)

        let leadingEnvironment = environment
            .with(\.navigationAction) {
                backend.showColumn(.detail, ofSplitView: widget)
            }
        children.minimumLeadingWidth =
            children.leadingChild.computeLayout(
                with: body.view0,
                proposedSize: ProposedViewSize(
                    0,
                    proposedSize.height
                ) - leadingPanePadding,
                environment: leadingEnvironment
                    .with(\.allowLayoutCaching, true)
            ).size.width + Double(leadingPanePadding.x)

        children.minimumTrailingWidth =
            children.trailingChild.computeLayout(
                with: body.view1,
                proposedSize: ProposedViewSize(
                    0,
                    proposedSize.height
                ) - trailingPanePadding,
                environment: environment
                    .with(\.allowLayoutCaching, true)
            ).size.width + Double(trailingPanePadding.x)

        let leadingWidthProposal: Double?
        let visibleColumns = backend.visibleColumns(ofSplitView: widget)
        if visibleColumns.count == 1 {
            leadingWidthProposal = proposedSize.width
        } else {
            leadingWidthProposal = proposedSize.width == nil ? nil : leadingWidth
        }

        // TODO: Figure out proper fixedSize behaviour (when width is unspecified)
        // Update pane children
        let leadingResult = children.leadingChild.computeLayout(
            with: body.view0,
            proposedSize: ProposedViewSize(
                leadingWidthProposal,
                proposedSize.height
            ) - leadingPanePadding,
            environment: leadingEnvironment
        )

        let trailingWidthProposal: Double?
        if visibleColumns.count == 1 {
            trailingWidthProposal = proposedSize.width
        } else {
            trailingWidthProposal = proposedSize.width.map { width in
                width - max(leadingWidth, leadingResult.size.width)
            }
        }

        let trailingResult = children.trailingChild.computeLayout(
            with: body.view1,
            proposedSize: ProposedViewSize(
                trailingWidthProposal,
                proposedSize.height
            ) - trailingPanePadding,
            environment: environment
        )

        // Update split view size and sidebar width bounds
        let leadingContentSize = leadingResult.size
        let trailingContentSize = trailingResult.size
        var size = ViewSize.zero
        if visibleColumns.contains(.sidebar) {
            size.width += leadingContentSize.width + Double(leadingPanePadding.x)
            size.height = max(
                size.height,
                leadingContentSize.height + Double(leadingPanePadding.y)
            )
        }
        if visibleColumns.contains(.detail) {
            size.width += trailingContentSize.width + Double(leadingPanePadding.x)
            size.height = max(
                size.height,
                trailingContentSize.height + Double(trailingPanePadding.y)
            )
        }

        if let proposedWidth = proposedSize.width {
            size.width = max(size.width, proposedWidth)
        }
        if let proposedHeight = proposedSize.height {
            size.height = max(size.height, proposedHeight)
        }

        return ViewLayoutResult(
            size: size,
            childResults: [leadingResult, trailingResult]
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setResizeHandler(ofSplitView: widget) {
            // The parameter to onResize is currently unused
            environment.onResize(.zero)
        }

        // Even when only one column is visible, we commit both so that the
        // hidden column is always ready for user-initiated transitions.
        let leadingResult = children.leadingChild.commit()
        let trailingResult = children.trailingChild.commit()

        let leadingWidth = backend.sidebarWidth(ofSplitView: widget)

        let size = layout.size.vector
        backend.setSize(of: widget, to: size)
        backend.setSidebarWidthBounds(
            ofSplitView: widget,
            minimum: LayoutSystem.roundSize(children.minimumLeadingWidth),
            maximum: LayoutSystem.roundSize(
                max(
                    children.minimumLeadingWidth,
                    layout.size.width - children.minimumTrailingWidth
                )
            )
        )
        
        let visibleColumns = backend.visibleColumns(ofSplitView: widget)
        if visibleColumns.count == 1 {
            // UIKit needs these, otherwise its panes get a 0x0 container around
            // them, which prevents them from receiving any clicks.
            backend.setSize(
                of: children.leadingPaneContainer.into(),
                to: layout.size.vector
            )
            backend.setSize(
                of: children.trailingPaneContainer.into(),
                to: layout.size.vector
            )
        }

        let leadingInternalPadding = backend.internalPadding(
            ofSplitView: widget,
            column: .sidebar
        )
        let trailingInternalPadding = backend.internalPadding(
            ofSplitView: widget,
            column: .detail
        )
        let leadingPaneSize: SIMD2<Int>
        let trailingPaneSize: SIMD2<Int>
        if visibleColumns.count == 1 {
            // Center pane children
            leadingPaneSize = size &- leadingInternalPadding
            trailingPaneSize = size &- trailingInternalPadding
        } else {
            // Center pane children
            leadingPaneSize = SIMD2(
                leadingWidth,
                size.y
            ) &- leadingInternalPadding
            trailingPaneSize = SIMD2(
                size.x - leadingWidth,
                size.y
            ) &- trailingInternalPadding
        }

        backend.setPosition(
            ofChildAt: 0,
            in: children.leadingPaneContainer.into(),
            to: Alignment.center.position(
                ofChild: leadingResult.size.vector,
                in: leadingPaneSize
            )
        )
        backend.setPosition(
            ofChildAt: 0,
            in: children.trailingPaneContainer.into(),
            to: Alignment.center.position(
                ofChild: trailingResult.size.vector,
                in: trailingPaneSize
            )
        )
    }
}

class SplitViewChildren<Sidebar: View, Detail: View>: ViewGraphNodeChildren {
    var paneChildren: TupleView2<Sidebar, Detail>.Children
    var leadingPaneContainer: AnyWidget
    var trailingPaneContainer: AnyWidget
    var minimumLeadingWidth: Double
    var minimumTrailingWidth: Double

    init<Backend: BaseAppBackend>(
        wrapping children: TupleView2<Sidebar, Detail>.Children,
        backend: Backend
    ) {
        self.paneChildren = children

        let leadingPaneContainer = backend.createContainer()
        backend.insert(
            paneChildren.child0.widget.into(),
            into: leadingPaneContainer,
            at: 0
        )
        let trailingPaneContainer = backend.createContainer()
        backend.insert(
            paneChildren.child1.widget.into(),
            into: trailingPaneContainer,
            at: 0
        )

        self.leadingPaneContainer = AnyWidget(leadingPaneContainer)
        self.trailingPaneContainer = AnyWidget(trailingPaneContainer)
        self.minimumLeadingWidth = 0
        self.minimumTrailingWidth = 0
    }

    var erasedNodes: [ErasedViewGraphNode] {
        paneChildren.erasedNodes
    }

    var widgets: [AnyWidget] {
        [
            leadingPaneContainer,
            trailingPaneContainer,
        ]
    }

    var leadingChild: AnyViewGraphNode<Sidebar> {
        paneChildren.child0
    }

    var trailingChild: AnyViewGraphNode<Detail> {
        paneChildren.child1
    }
}
