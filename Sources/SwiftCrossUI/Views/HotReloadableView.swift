import Foundation

/// A view which attempts to persist the state of its view subtree even
/// when the subtree's structure changes. Uses state serialization (via
/// view graph snapshotting) to persist view state even when a child
/// view's implementation gets swapped out with an implementation from
/// a newly-loaded dylib (this is what makes this useful for hot reloading).
///
/// Only expected to be used directly by SwiftCrossUI itself or third
/// party libraries extending SwiftCrossUI's hot reloading capabilities.
public struct HotReloadableView: TypeSafeView {
    typealias Children = HotReloadableViewChildren

    public var body = EmptyView()

    var child: any View

    public init(_ child: any View) {
        self.child = child
    }

    public init(@ViewBuilder _ child: () -> some View) {
        self.child = child()
    }

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> HotReloadableViewChildren {
        let snapshot = snapshots?.count == 1 ? snapshots?.first : nil
        return HotReloadableViewChildren(
            from: self,
            backend: backend,
            snapshot: snapshot,
            environment: environment
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: HotReloadableViewChildren,
        backend: Backend
    ) -> Backend.Widget {
        backend.createContainer()
    }

    /// Attempts to update the child. If the initial update succeeds then the child's concrete type
    /// hasn't changed and the ViewGraph has handled state persistence on our behalf. Otherwise,
    /// we must recreate the child node and swap out our current child widget with the new view's
    /// widget. Before displaying the child, we also attempt to transfer a snapshot of the old
    /// view graph sub tree's state onto the new view graph sub tree. This is not possible to do
    /// perfectly by definition, so if we can't successfully transfer the state of the sub tree
    /// we just fall back on the failing view's default state.
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: HotReloadableViewChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var (viewTypeMatched, result) = children.node.computeLayoutWithNewView(
            child,
            proposedSize,
            environment
        )

        if !viewTypeMatched {
            let snapshotter = ViewGraphSnapshotter()
            let snapshot = children.node.transform(with: snapshotter)
            children.node = ErasedViewGraphNode(
                for: child,
                backend: backend,
                snapshot: snapshot,
                environment: environment
            )

            // We can assume that the view types match since we just recreated the view
            // on the line above.
            let (_, newResult) = children.node.computeLayoutWithNewView(
                child,
                proposedSize,
                environment
            )
            result = newResult
            children.hasChangedChild = true
        }

        return result
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: HotReloadableViewChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        if children.hasChangedChild {
            backend.removeAllChildren(of: widget)
            backend.insert(children.node.getWidget().into(), into: widget, at: 0)
            backend.setPosition(ofChildAt: 0, in: widget, to: .zero)
            children.hasChangedChild = false
        }

        _ = children.node.commit()

        backend.setSize(of: widget, to: layout.size.vector)
    }
}

class HotReloadableViewChildren: ViewGraphNodeChildren {
    /// The erased underlying node.
    var node: ErasedViewGraphNode

    var widgets: [AnyWidget] {
        [node.getWidget()]
    }

    var erasedNodes: [ErasedViewGraphNode] {
        [node]
    }

    var hasChangedChild = true

    /// Creates the erased child node and wraps the child's widget in a single-child container.
    init<Backend: BaseAppBackend>(
        from view: HotReloadableView,
        backend: Backend,
        snapshot: ViewGraphSnapshotter.NodeSnapshot?,
        environment: EnvironmentValues
    ) {
        node = ErasedViewGraphNode(
            for: view.child,
            backend: backend,
            snapshot: snapshot,
            environment: environment
        )
    }
}
