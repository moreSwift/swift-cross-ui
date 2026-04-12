// This file was generated using gyb. Do not edit it directly. Edit
// TupleViewChildren.swift.gyb instead.

protocol TupleViewChildren: ViewGraphNodeChildren {
    @MainActor
    var stackLayoutCache: StackLayoutCache { get nonmutating set }
}

/// A helper function to shorten node initialisations to a single line. This
/// helps compress the generated code a bit and minimise the number of additions
/// and deletions caused by updating the generator.
@MainActor
private func node<V: View, Backend: BaseAppBackend>(
    for view: V,
    _ backend: Backend,
    _ snapshot: ViewGraphSnapshotter.NodeSnapshot?,
    _ environment: EnvironmentValues
) -> AnyViewGraphNode<V> {
    AnyViewGraphNode(
        for: view,
        backend: backend,
        snapshot: snapshot,
        environment: environment
    )
}

/// A fixed-length strongly-typed collection of 1 child nodes. A counterpart to
/// ``TupleView1``.
public class TupleViewChildren1<Child0: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>

    /// Creates the nodes for 1 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
    }
}

/// A fixed-length strongly-typed collection of 2 child nodes. A counterpart to
/// ``TupleView2``.
public class TupleViewChildren2<Child0: View, Child1: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>

    /// Creates the nodes for 2 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
    }
}

/// A fixed-length strongly-typed collection of 3 child nodes. A counterpart to
/// ``TupleView3``.
public class TupleViewChildren3<Child0: View, Child1: View, Child2: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>

    /// Creates the nodes for 3 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
    }
}

/// A fixed-length strongly-typed collection of 4 child nodes. A counterpart to
/// ``TupleView4``.
public class TupleViewChildren4<Child0: View, Child1: View, Child2: View, Child3: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>

    /// Creates the nodes for 4 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
    }
}

/// A fixed-length strongly-typed collection of 5 child nodes. A counterpart to
/// ``TupleView5``.
public class TupleViewChildren5<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>

    /// Creates the nodes for 5 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
    }
}

/// A fixed-length strongly-typed collection of 6 child nodes. A counterpart to
/// ``TupleView6``.
public class TupleViewChildren6<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>

    /// Creates the nodes for 6 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
    }
}

/// A fixed-length strongly-typed collection of 7 child nodes. A counterpart to
/// ``TupleView7``.
public class TupleViewChildren7<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>

    /// Creates the nodes for 7 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
    }
}

/// A fixed-length strongly-typed collection of 8 child nodes. A counterpart to
/// ``TupleView8``.
public class TupleViewChildren8<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>

    /// Creates the nodes for 8 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
    }
}

/// A fixed-length strongly-typed collection of 9 child nodes. A counterpart to
/// ``TupleView9``.
public class TupleViewChildren9<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>

    /// Creates the nodes for 9 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
    }
}

/// A fixed-length strongly-typed collection of 10 child nodes. A counterpart to
/// ``TupleView10``.
public class TupleViewChildren10<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>

    /// Creates the nodes for 10 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
    }
}

/// A fixed-length strongly-typed collection of 11 child nodes. A counterpart to
/// ``TupleView11``.
public class TupleViewChildren11<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>

    /// Creates the nodes for 11 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
    }
}

/// A fixed-length strongly-typed collection of 12 child nodes. A counterpart to
/// ``TupleView12``.
public class TupleViewChildren12<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>

    /// Creates the nodes for 12 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
    }
}

/// A fixed-length strongly-typed collection of 13 child nodes. A counterpart to
/// ``TupleView13``.
public class TupleViewChildren13<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>

    /// Creates the nodes for 13 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
    }
}

/// A fixed-length strongly-typed collection of 14 child nodes. A counterpart to
/// ``TupleView14``.
public class TupleViewChildren14<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>

    /// Creates the nodes for 14 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
    }
}

/// A fixed-length strongly-typed collection of 15 child nodes. A counterpart to
/// ``TupleView15``.
public class TupleViewChildren15<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>

    /// Creates the nodes for 15 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
    }
}

/// A fixed-length strongly-typed collection of 16 child nodes. A counterpart to
/// ``TupleView16``.
public class TupleViewChildren16<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View, Child15: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget, child15.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
            ErasedViewGraphNode(wrapping: child15),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child15: AnyViewGraphNode<Child15>

    /// Creates the nodes for 16 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14, _ child15: Child15,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self), ViewGraphSnapshotter.name(of: Child15.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
        self.child15 = node(for: child15, backend, snapshots[15], environment)
    }
}

/// A fixed-length strongly-typed collection of 17 child nodes. A counterpart to
/// ``TupleView17``.
public class TupleViewChildren17<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View, Child15: View, Child16: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget, child15.widget, child16.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
            ErasedViewGraphNode(wrapping: child15),
            ErasedViewGraphNode(wrapping: child16),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child15: AnyViewGraphNode<Child15>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child16: AnyViewGraphNode<Child16>

    /// Creates the nodes for 17 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14, _ child15: Child15, _ child16: Child16,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self), ViewGraphSnapshotter.name(of: Child15.self), ViewGraphSnapshotter.name(of: Child16.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
        self.child15 = node(for: child15, backend, snapshots[15], environment)
        self.child16 = node(for: child16, backend, snapshots[16], environment)
    }
}

/// A fixed-length strongly-typed collection of 18 child nodes. A counterpart to
/// ``TupleView18``.
public class TupleViewChildren18<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View, Child15: View, Child16: View, Child17: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget, child15.widget, child16.widget, child17.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
            ErasedViewGraphNode(wrapping: child15),
            ErasedViewGraphNode(wrapping: child16),
            ErasedViewGraphNode(wrapping: child17),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child15: AnyViewGraphNode<Child15>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child16: AnyViewGraphNode<Child16>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child17: AnyViewGraphNode<Child17>

    /// Creates the nodes for 18 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14, _ child15: Child15, _ child16: Child16, _ child17: Child17,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self), ViewGraphSnapshotter.name(of: Child15.self), ViewGraphSnapshotter.name(of: Child16.self), ViewGraphSnapshotter.name(of: Child17.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
        self.child15 = node(for: child15, backend, snapshots[15], environment)
        self.child16 = node(for: child16, backend, snapshots[16], environment)
        self.child17 = node(for: child17, backend, snapshots[17], environment)
    }
}

/// A fixed-length strongly-typed collection of 19 child nodes. A counterpart to
/// ``TupleView19``.
public class TupleViewChildren19<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View, Child15: View, Child16: View, Child17: View, Child18: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget, child15.widget, child16.widget, child17.widget, child18.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
            ErasedViewGraphNode(wrapping: child15),
            ErasedViewGraphNode(wrapping: child16),
            ErasedViewGraphNode(wrapping: child17),
            ErasedViewGraphNode(wrapping: child18),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child15: AnyViewGraphNode<Child15>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child16: AnyViewGraphNode<Child16>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child17: AnyViewGraphNode<Child17>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child18: AnyViewGraphNode<Child18>

    /// Creates the nodes for 19 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14, _ child15: Child15, _ child16: Child16, _ child17: Child17, _ child18: Child18,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self), ViewGraphSnapshotter.name(of: Child15.self), ViewGraphSnapshotter.name(of: Child16.self), ViewGraphSnapshotter.name(of: Child17.self), ViewGraphSnapshotter.name(of: Child18.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
        self.child15 = node(for: child15, backend, snapshots[15], environment)
        self.child16 = node(for: child16, backend, snapshots[16], environment)
        self.child17 = node(for: child17, backend, snapshots[17], environment)
        self.child18 = node(for: child18, backend, snapshots[18], environment)
    }
}

/// A fixed-length strongly-typed collection of 20 child nodes. A counterpart to
/// ``TupleView20``.
public class TupleViewChildren20<Child0: View, Child1: View, Child2: View, Child3: View, Child4: View, Child5: View, Child6: View, Child7: View, Child8: View, Child9: View, Child10: View, Child11: View, Child12: View, Child13: View, Child14: View, Child15: View, Child16: View, Child17: View, Child18: View, Child19: View>: TupleViewChildren {
    public var widgets: [AnyWidget] {
        return [child0.widget, child1.widget, child2.widget, child3.widget, child4.widget, child5.widget, child6.widget, child7.widget, child8.widget, child9.widget, child10.widget, child11.widget, child12.widget, child13.widget, child14.widget, child15.widget, child16.widget, child17.widget, child18.widget, child19.widget]
    }

    public var erasedNodes: [ErasedViewGraphNode] {
        return [
            ErasedViewGraphNode(wrapping: child0),
            ErasedViewGraphNode(wrapping: child1),
            ErasedViewGraphNode(wrapping: child2),
            ErasedViewGraphNode(wrapping: child3),
            ErasedViewGraphNode(wrapping: child4),
            ErasedViewGraphNode(wrapping: child5),
            ErasedViewGraphNode(wrapping: child6),
            ErasedViewGraphNode(wrapping: child7),
            ErasedViewGraphNode(wrapping: child8),
            ErasedViewGraphNode(wrapping: child9),
            ErasedViewGraphNode(wrapping: child10),
            ErasedViewGraphNode(wrapping: child11),
            ErasedViewGraphNode(wrapping: child12),
            ErasedViewGraphNode(wrapping: child13),
            ErasedViewGraphNode(wrapping: child14),
            ErasedViewGraphNode(wrapping: child15),
            ErasedViewGraphNode(wrapping: child16),
            ErasedViewGraphNode(wrapping: child17),
            ErasedViewGraphNode(wrapping: child18),
            ErasedViewGraphNode(wrapping: child19),
        ]
    }

    var stackLayoutCache = StackLayoutCache.initial

    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child0: AnyViewGraphNode<Child0>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child1: AnyViewGraphNode<Child1>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child2: AnyViewGraphNode<Child2>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child3: AnyViewGraphNode<Child3>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child4: AnyViewGraphNode<Child4>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child5: AnyViewGraphNode<Child5>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child6: AnyViewGraphNode<Child6>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child7: AnyViewGraphNode<Child7>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child8: AnyViewGraphNode<Child8>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child9: AnyViewGraphNode<Child9>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child10: AnyViewGraphNode<Child10>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child11: AnyViewGraphNode<Child11>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child12: AnyViewGraphNode<Child12>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child13: AnyViewGraphNode<Child13>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child14: AnyViewGraphNode<Child14>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child15: AnyViewGraphNode<Child15>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child16: AnyViewGraphNode<Child16>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child17: AnyViewGraphNode<Child17>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child18: AnyViewGraphNode<Child18>
    /// ``AnyViewGraphNode`` is used instead of ``ViewGraphNode`` because otherwise the backend leaks into views.
    public var child19: AnyViewGraphNode<Child19>

    /// Creates the nodes for 20 child views.
    public init<Backend: BaseAppBackend>(
        _ child0: Child0, _ child1: Child1, _ child2: Child2, _ child3: Child3, _ child4: Child4, _ child5: Child5, _ child6: Child6, _ child7: Child7, _ child8: Child8, _ child9: Child9, _ child10: Child10, _ child11: Child11, _ child12: Child12, _ child13: Child13, _ child14: Child14, _ child15: Child15, _ child16: Child16, _ child17: Child17, _ child18: Child18, _ child19: Child19,
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        let viewTypeNames = [
            ViewGraphSnapshotter.name(of: Child0.self), ViewGraphSnapshotter.name(of: Child1.self), ViewGraphSnapshotter.name(of: Child2.self), ViewGraphSnapshotter.name(of: Child3.self), ViewGraphSnapshotter.name(of: Child4.self), ViewGraphSnapshotter.name(of: Child5.self), ViewGraphSnapshotter.name(of: Child6.self), ViewGraphSnapshotter.name(of: Child7.self), ViewGraphSnapshotter.name(of: Child8.self), ViewGraphSnapshotter.name(of: Child9.self), ViewGraphSnapshotter.name(of: Child10.self), ViewGraphSnapshotter.name(of: Child11.self), ViewGraphSnapshotter.name(of: Child12.self), ViewGraphSnapshotter.name(of: Child13.self), ViewGraphSnapshotter.name(of: Child14.self), ViewGraphSnapshotter.name(of: Child15.self), ViewGraphSnapshotter.name(of: Child16.self), ViewGraphSnapshotter.name(of: Child17.self), ViewGraphSnapshotter.name(of: Child18.self), ViewGraphSnapshotter.name(of: Child19.self)
        ]
        let snapshots = ViewGraphSnapshotter.match(snapshots ?? [], to: viewTypeNames)
        self.child0 = node(for: child0, backend, snapshots[0], environment)
        self.child1 = node(for: child1, backend, snapshots[1], environment)
        self.child2 = node(for: child2, backend, snapshots[2], environment)
        self.child3 = node(for: child3, backend, snapshots[3], environment)
        self.child4 = node(for: child4, backend, snapshots[4], environment)
        self.child5 = node(for: child5, backend, snapshots[5], environment)
        self.child6 = node(for: child6, backend, snapshots[6], environment)
        self.child7 = node(for: child7, backend, snapshots[7], environment)
        self.child8 = node(for: child8, backend, snapshots[8], environment)
        self.child9 = node(for: child9, backend, snapshots[9], environment)
        self.child10 = node(for: child10, backend, snapshots[10], environment)
        self.child11 = node(for: child11, backend, snapshots[11], environment)
        self.child12 = node(for: child12, backend, snapshots[12], environment)
        self.child13 = node(for: child13, backend, snapshots[13], environment)
        self.child14 = node(for: child14, backend, snapshots[14], environment)
        self.child15 = node(for: child15, backend, snapshots[15], environment)
        self.child16 = node(for: child16, backend, snapshots[16], environment)
        self.child17 = node(for: child17, backend, snapshots[17], environment)
        self.child18 = node(for: child18, backend, snapshots[18], environment)
        self.child19 = node(for: child19, backend, snapshots[19], environment)
    }
}
