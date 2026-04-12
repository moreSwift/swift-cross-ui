extension View {
    /// Adds an action to be performed after this view disappears.
    ///
    /// `onDisappear` actions on outermost views are called first and propagate
    /// down to the leaf views due to essentially relying on the `deinit` of the
    /// modifier view's ``ViewGraphNode``.
    ///
    /// - Parameter action: The action to perform when this view disappears.
    public func onDisappear(perform action: @escaping @Sendable @MainActor () -> Void) -> some View
    {
        OnDisappearModifier(body: TupleView1(self), action: action)
    }
}

struct OnDisappearModifier<Content: View>: TypeSafeView {
    var body: TupleView1<Content>
    var action: @Sendable @MainActor () -> Void

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> OnDisappearModifierChildren {
        OnDisappearModifierChildren(
            wrappedChildren: defaultChildren(
                backend: backend,
                snapshots: snapshots,
                environment: environment
            ),
            action: action
        )
    }

    func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: OnDisappearModifierChildren
    ) -> [LayoutSystem.LayoutableChild] {
        defaultLayoutableChildren(
            backend: backend,
            children: children.wrappedChildren
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: OnDisappearModifierChildren,
        backend: Backend
    ) -> Backend.Widget {
        defaultAsWidget(children.wrappedChildren, backend: backend)
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: OnDisappearModifierChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        defaultComputeLayout(
            widget,
            children: children.wrappedChildren,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: OnDisappearModifierChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        defaultCommit(
            widget,
            children: children.wrappedChildren,
            layout: layout,
            environment: environment,
            backend: backend
        )
    }
}

class OnDisappearModifierChildren: ViewGraphNodeChildren {
    var wrappedChildren: any ViewGraphNodeChildren
    var action: @Sendable @MainActor () -> Void

    var widgets: [AnyWidget] {
        wrappedChildren.widgets
    }

    var erasedNodes: [ErasedViewGraphNode] {
        wrappedChildren.erasedNodes
    }

    init(
        wrappedChildren: any ViewGraphNodeChildren,
        action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.wrappedChildren = wrappedChildren
        self.action = action
    }

    deinit {
        Task { @MainActor [action] in
            action()
        }
    }
}
