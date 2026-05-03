/// A view used by ``ViewBuilder`` to support if/else conditional statements.
public struct EitherView<A: View, B: View> {
    typealias NodeChildren = EitherViewChildren<A, B>

    public var body = EmptyView()

    /// Stores one of two possible view types.
    enum Storage {
        case a(A)
        case b(B)
    }

    var storage: Storage

    /// Creates an either view with its first case visible initially.
    init(_ a: A) {
        storage = .a(a)
    }

    /// Creates an either view with its second case visible initially.
    init(_ b: B) {
        storage = .b(b)
    }
}

extension EitherView: View {
}

extension EitherView: TypeSafeView {
    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> NodeChildren {
        return EitherViewChildren(
            from: self,
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: EitherViewChildren<A, B>,
        backend: Backend
    ) -> Backend.Widget {
        return backend.createContainer()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: EitherViewChildren<A, B>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let result: ViewLayoutResult
        let hasSwitchedCase: Bool
        switch storage {
            case .a(let a):
                switch children.node {
                    case .a(let nodeA):
                        result = nodeA.computeLayout(
                            with: a,
                            proposedSize: proposedSize,
                            environment: environment
                        )
                        hasSwitchedCase = false
                    case .b:
                        let nodeA = AnyViewGraphNode(
                            for: a,
                            backend: backend,
                            environment: environment
                        )
                        children.node = .a(nodeA)
                        result = nodeA.computeLayout(
                            with: a,
                            proposedSize: proposedSize,
                            environment: environment
                        )
                        hasSwitchedCase = true
                }
            case .b(let b):
                switch children.node {
                    case .b(let nodeB):
                        result = nodeB.computeLayout(
                            with: b,
                            proposedSize: proposedSize,
                            environment: environment
                        )
                        hasSwitchedCase = false
                    case .a:
                        let nodeB = AnyViewGraphNode(
                            for: b,
                            backend: backend,
                            environment: environment
                        )
                        children.node = .b(nodeB)
                        result = nodeB.computeLayout(
                            with: b,
                            proposedSize: proposedSize,
                            environment: environment
                        )
                        hasSwitchedCase = true
                }
        }
        children.hasSwitchedCase = children.hasSwitchedCase || hasSwitchedCase

        return result
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: EitherViewChildren<A, B>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        if children.hasSwitchedCase {
            backend.removeAllChildren(of: widget)
            backend.insert(children.node.widget.into(), into: widget, at: 0)
            backend.setPosition(ofChildAt: 0, in: widget, to: .zero)
            children.hasSwitchedCase = false
        }

        _ = children.node.erasedNode.commit()

        backend.setSize(of: widget, to: layout.size.vector)
    }
}

/// Uses an `enum` to store a view graph node for one of two possible child view types.
class EitherViewChildren<A: View, B: View>: ViewGraphNodeChildren {
    /// A view graph node that wraps one of two possible child view types.
    @MainActor
    enum EitherNode {
        case a(AnyViewGraphNode<A>)
        case b(AnyViewGraphNode<B>)

        /// The widget corresponding to the currently displayed child view.
        var widget: AnyWidget {
            switch self {
                case .a(let node):
                    return node.widget
                case .b(let node):
                    return node.widget
            }
        }

        var erasedNode: ErasedViewGraphNode {
            switch self {
                case .a(let node):
                    return ErasedViewGraphNode(wrapping: node)
                case .b(let node):
                    return ErasedViewGraphNode(wrapping: node)
            }
        }
    }

    /// The view graph node for the currently displayed child.
    var node: EitherNode

    /// Tracks whether the view has switched cases since the last non-dryrun update.
    /// Initially `true`.
    var hasSwitchedCase = true

    var widgets: [AnyWidget] {
        return [node.widget]
    }

    var erasedNodes: [ErasedViewGraphNode] {
        [node.erasedNode]
    }

    /// Creates storage for an either view's current child (which can change at any time).
    init<Backend: BaseAppBackend>(
        from view: EitherView<A, B>,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        // TODO: Ensure that this is valid in all circumstances. It should be, given that
        //   we're assuming that the parent view's state was restored from the same snapshot
        //   which should mean that the same EitherView case will be selected (if we assume
        //   that views are pure, which we have to).
        let snapshot = snapshots?.first
        switch view.storage {
            case .a(let a):
                node = .a(
                    AnyViewGraphNode(
                        for: a,
                        backend: backend,
                        snapshot: snapshot,
                        environment: environment
                    )
                )
            case .b(let b):
                node = .b(
                    AnyViewGraphNode(
                        for: b,
                        backend: backend,
                        snapshot: snapshot,
                        environment: environment
                    )
                )
        }
    }
}
