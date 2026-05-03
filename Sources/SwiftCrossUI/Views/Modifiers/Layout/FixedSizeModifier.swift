extension View {
    /// Locks this view's size on both the horizontal and vertical axes.
    public func fixedSize() -> some View {
        FixedSizeModifier(self, horizontal: true, vertical: true)
    }

    /// Locks this view's size on the specified axes.
    ///
    /// What this modifier does is propose an unspecified size along the specified
    /// dimensions; this has the effect of making the view immune to changes in
    /// size proposals along its 'fixed' axes. But the view's size along those
    /// axes **may still change** if the incoming size proposal changes along a
    /// 'non-fixed' axis. This is particularly pertinent in the case of views like
    /// ``Text``, which have a tradeoff between width and height; a 'fixed'
    /// horizontal size can still change if the vertical size changes, and vice
    /// versa.
    ///
    /// If both `horizontal` and `vertical` are `true` (i.e. if both axes are
    /// 'fixed'), then the child will take on its ideal size along both axes and
    /// will _actually_ be of a fixed size. ``fixedSize()`` (with no arguments)
    /// provides a shorthand for this.
    ///
    /// - Parameters:
    ///   - horizontal: Whether to lock this view's size on the horizontal axis.
    ///   - vertical: Whether to lock this view's size on the vertical axis.
    public func fixedSize(horizontal: Bool, vertical: Bool) -> some View {
        FixedSizeModifier(self, horizontal: horizontal, vertical: vertical)
    }
}

struct FixedSizeModifier<Child: View>: TypeSafeView {
    var body: TupleView1<Child>

    var horizontal: Bool
    var vertical: Bool

    init(_ child: Child, horizontal: Bool, vertical: Bool) {
        body = TupleView1(child)
        self.horizontal = horizontal
        self.vertical = vertical
    }

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> TupleViewChildren1<Child> {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: TupleViewChildren1<Child>,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createContainer()
        backend.insert(children.child0.widget.into(), into: container, at: 0)
        return container
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var childProposal = proposedSize
        if horizontal {
            childProposal.width = nil
        }
        if vertical {
            childProposal.height = nil
        }
        let childResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: childProposal,
            environment: environment
        )

        return ViewLayoutResult(
            size: childResult.size,
            childResults: [childResult]
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let childResult = children.child0.commit()
        let childPosition = Alignment.center.position(
            ofChild: childResult.size.vector,
            in: layout.size.vector
        )
        backend.setPosition(ofChildAt: 0, in: widget, to: childPosition)
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
