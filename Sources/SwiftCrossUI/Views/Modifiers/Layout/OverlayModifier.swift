extension View {
    /// Overlays another view on top of this view.
    ///
    /// - Parameter content: The view to overlay this view with.
    public func overlay(@ViewBuilder content: () -> some View) -> some View {
        OverlayModifier(content: self, overlay: content())
    }
}

struct OverlayModifier<Content: View, Overlay: View>: TypeSafeView {
    typealias Children = TupleView2<Content, Overlay>.Children

    var body: TupleView2<Content, Overlay>

    init(content: Content, overlay: Overlay) {
        body = TupleView2(content, overlay)
    }

    func children<Backend: AppBackend.Base>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> TupleView2<Content, Overlay>.Children {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    func layoutableChildren<Backend: AppBackend.Base>(
        backend: Backend,
        children: TupleView2<Content, Overlay>.Children
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    func asWidget<Backend: AppBackend.Base>(
        _ children: TupleView2<Content, Overlay>.Children, backend: Backend
    ) -> Backend.Widget {
        body.asWidget(children, backend: backend)
    }

    func computeLayout<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        children: TupleView2<Content, Overlay>.Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let contentResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        let contentSize = contentResult.size
        let overlayResult = children.child1.computeLayout(
            with: body.view1,
            proposedSize: ProposedViewSize(contentSize),
            environment: environment
        )
        let overlaySize = overlayResult.size

        let size = ViewSize(
            max(contentSize.width, overlaySize.width),
            max(contentSize.height, overlaySize.height)
        )

        return ViewLayoutResult(
            size: size,
            childResults: [contentResult, overlayResult]
        )
    }

    func commit<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        children: TupleView2<Content, Overlay>.Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let frameSize = layout.size.vector
        let contentSize = children.child0.commit().size.vector
        let overlaySize = children.child1.commit().size.vector

        let contentPosition = Alignment.center.position(ofChild: contentSize, in: frameSize)
        let overlayPosition = Alignment.center.position(ofChild: overlaySize, in: frameSize)

        backend.setPosition(ofChildAt: 0, in: widget, to: contentPosition)
        backend.setPosition(ofChildAt: 1, in: widget, to: overlayPosition)

        backend.setSize(of: widget, to: frameSize)
    }
}
