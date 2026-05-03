/// A placeholder view used by elementary ``View`` implementations which don't
/// have bodies.
///
/// Triggers a fatal error if rendered.
public struct EmptyView: View, Sendable {
    /// The nonexistent body of an ``EmptyView``.
    ///
    /// - Warning: Do not access this property directly; it will trigger a fatal
    ///   error at runtime.
    public var body: Never {
        return fatalError("Rendered EmptyView")
    }

    /// Creates an instance of ``EmptyView``.
    ///
    /// This will crash if used in a ``View`` that doesn't override the default
    /// widget creation code; it's not intended for regular use.
    public nonisolated init() {}

    public func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        return EmptyViewChildren()
    }

    public func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    public func updateChildren<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) {}

    public func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        backend.createContainer()
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        ViewLayoutResult.leafView(size: .zero)
    }

    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {}
}

/// The children of a node with no children.
public struct EmptyViewChildren: ViewGraphNodeChildren {
    public let widgets: [AnyWidget] = []
    public let erasedNodes: [ErasedViewGraphNode] = []

    /// Creates an empty collection of children for a node with no children.
    public init() {}
}

/// Used as the body of ``EmptyView`` to end the chain of view bodies.
extension Never: View {
    public var body: Never {
        return fatalError("Rendered Never")
    }

    public init() {
        fatalError("Cannot create never")
    }
}
