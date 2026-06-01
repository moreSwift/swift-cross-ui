import Foundation

extension View {
    /// Adds an action to be performed after this view disappears.
    ///
    /// `onDisappear` actions on outermost views are called first and propagate
    /// down to the leaf views due to essentially relying on the `deinit` of the
    /// modifier view's ``ViewGraphNode``.
    public func onDisappear(perform action: @escaping @Sendable @MainActor () -> Void) -> some View
    {
        OnDisappearModifier(body: TupleView1(self), action: action)
    }
}

struct OnDisappearModifier<Content: View>: View {
    var body: TupleView1<Content>
    var action: @Sendable @MainActor () -> Void

    func children<Backend: AppBackend>(
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

    func layoutableChildren<Backend: AppBackend>(
        backend: Backend,
        children: OnDisappearModifierChildren
    ) -> [LayoutSystem.LayoutableChild] {
        defaultLayoutableChildren(
            backend: backend,
            children: children.wrappedChildren
        )
    }

    func asWidget<Backend: AppBackend>(
        _ children: OnDisappearModifierChildren,
        backend: Backend
    ) -> Backend.Widget {
        defaultAsWidget(children.wrappedChildren, backend: backend)
    }

    func update<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: OnDisappearModifierChildren,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        backend: Backend,
        dryRun: Bool
    ) -> ViewUpdateResult {
        defaultUpdate(
            widget,
            children: children.wrappedChildren,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend,
            dryRun: dryRun
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
        if #available(iOS 13, *) {
            /*Task { @MainActor [action] in
                action()
            }*/
        } else {
            DispatchQueue.main.async {
                self.action()
            }
        }
    }
}
