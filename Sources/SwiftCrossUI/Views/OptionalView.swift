/// A view used by ``ViewBuilder`` to support non-exhaustive if statements.
public struct OptionalView<V: View> {
    public var body = EmptyView()

    var view: V?

    /// Wraps an optional view.
    init(_ view: V?) {
        self.view = view
    }
}

extension OptionalView: View {
}

extension OptionalView: TypeSafeView {
    typealias Children = OptionalViewChildren<V>

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> OptionalViewChildren<V> {
        // TODO: This is a conservative implementation, perhaps there are some situations
        //   where we could usefully use the snapshots even if there are too many.
        let snapshot = snapshots?.count == 1 ? snapshots?.first : nil
        return OptionalViewChildren(
            from: view,
            backend: backend,
            snapshot: snapshot,
            environment: environment
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: OptionalViewChildren<V>,
        backend: Backend
    ) -> Backend.Widget {
        return backend.createContainer()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: OptionalViewChildren<V>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let hasToggled: Bool
        let result: ViewLayoutResult
        if let view {
            if let node = children.node {
                result = node.computeLayout(
                    with: view,
                    proposedSize: proposedSize,
                    environment: environment
                )
                hasToggled = false
            } else {
                let node = AnyViewGraphNode(
                    for: view,
                    backend: backend,
                    environment: environment
                )
                children.node = node
                result = node.computeLayout(
                    with: view,
                    proposedSize: proposedSize,
                    environment: environment
                )
                hasToggled = true
            }
        } else {
            hasToggled = children.node != nil
            children.node = nil
            result = ViewLayoutResult.leafView(size: .zero)
        }
        children.hasToggled = children.hasToggled || hasToggled

        return result
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: OptionalViewChildren<V>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        if children.hasToggled {
            backend.removeAllChildren(of: widget)
            if let node = children.node {
                backend.insert(node.widget.into(), into: widget, at: 0)
                backend.setPosition(ofChildAt: 0, in: widget, to: .zero)
            }
            children.hasToggled = false
        }

        _ = children.node?.commit()

        backend.setSize(of: widget, to: layout.size.vector)
    }
}

/// Stores a view graph node for the view's child if present. Tracks whether
/// the child has toggled since last time the parent was updated or not.
class OptionalViewChildren<V: View>: ViewGraphNodeChildren {
    /// The view graph node for the view's child if present.
    var node: AnyViewGraphNode<V>?
    /// Whether the view has toggled since the last non-dryrun update. `true`
    /// if the first view update hasn't occurred yet.
    var hasToggled = true

    var widgets: [AnyWidget] {
        return [node?.widget].compactMap { $0 }
    }

    var erasedNodes: [ErasedViewGraphNode] {
        if let node {
            [ErasedViewGraphNode(wrapping: node)]
        } else {
            []
        }
    }

    /// Creates storage for an optional view's child if present (which can change at
    /// any time).
    init<Backend: BaseAppBackend>(
        from view: V?,
        backend: Backend,
        snapshot: ViewGraphSnapshotter.NodeSnapshot?,
        environment: EnvironmentValues
    ) {
        if let view {
            node = AnyViewGraphNode(
                for: view,
                backend: backend,
                snapshot: snapshot,
                environment: environment
            )
        }
    }
}
