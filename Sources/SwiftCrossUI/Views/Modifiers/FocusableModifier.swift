extension View {
    /// Controls the focusability of a view.
    ///
    /// Doesn't have an effect on UIKitBackend and WinUIBackend.
    public func focusable(_ focusability: Focusability = .unmodified) -> some View {
        FocusableModifier(body: TupleView1(self), focusability: focusability)
    }
}

struct FocusableModifier<Content: View>: TypeSafeView {
    typealias Children = TupleView1<Content>.Children

    var body: TupleView1<Content>
    var focusability: Focusability

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createFocusContainer()

        backend.insert(children.child0.widget.into(), into: container, at: 0)

        return container as! Backend.Widget
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        .with(\.isNeverFocusable, false)
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = children.child0.commit().size.vector
        backend.setSize(of: widget, to: size)

        backend.updateFocusContainer(widget, focusability: focusability)
    }
}
