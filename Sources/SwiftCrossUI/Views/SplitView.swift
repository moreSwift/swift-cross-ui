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

        // TODO: If computeLayout ever becomes a pure requirement of View, then we
        //   can delay this until commit.
        children.minimumLeadingWidth =
            children.leadingChild.computeLayout(
                with: body.view0,
                proposedSize: ProposedViewSize(
                    0,
                    proposedSize.height
                ),
                environment: environment
            ).size.width

        children.minimumTrailingWidth =
            children.trailingChild.computeLayout(
                with: body.view1,
                proposedSize: ProposedViewSize(
                    0,
                    proposedSize.height
                ),
                environment: environment
            ).size.width

        // TODO: Figure out proper fixedSize behaviour (when width is unspecified)
        // Update pane children
        let leadingResult = children.leadingChild.computeLayout(
            with: body.view0,
            proposedSize: ProposedViewSize(
                proposedSize.width == nil ? nil : leadingWidth,
                proposedSize.height
            ),
            environment: environment
        )
        let trailingResult = children.trailingChild.computeLayout(
            with: body.view1,
            proposedSize: ProposedViewSize(
                proposedSize.width.map { $0 - max(leadingWidth, leadingResult.size.width) },
                proposedSize.height
            ),
            environment: environment
        )

        // Update split view size and sidebar width bounds
        let leadingContentSize = leadingResult.size
        let trailingContentSize = trailingResult.size
        var size = ViewSize(
            leadingContentSize.width + trailingContentSize.width,
            max(leadingContentSize.height, trailingContentSize.height)
        )

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

        let leadingWidth = backend.sidebarWidth(ofSplitView: widget)
        let leadingResult = children.leadingChild.commit()
        let trailingResult = children.trailingChild.commit()

        backend.setSize(of: widget, to: layout.size.vector)
        backend.setSidebarWidthBounds(
            ofSplitView: widget,
            minimum: LayoutSystem.roundSize(children.minimumLeadingWidth),
            maximum: LayoutSystem.roundSize(
                max(
                    children.minimumLeadingWidth,
                    layout.size.width - children.minimumTrailingWidth
                ))
        )

        // Center pane children
        backend.setPosition(
            ofChildAt: 0,
            in: children.leadingPaneContainer.into(),
            to: SIMD2(
                leadingWidth - leadingResult.size.vector.x,
                layout.size.vector.y - leadingResult.size.vector.y
            ) / 2
        )
        backend.setPosition(
            ofChildAt: 0,
            in: children.trailingPaneContainer.into(),
            to: SIMD2(
                layout.size.vector.x - leadingWidth - trailingResult.size.vector.x,
                layout.size.vector.y - trailingResult.size.vector.y
            ) / 2
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
