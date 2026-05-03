/// A type-erased ``ViewGraphNode``. Used by implementations of ``ViewGraphNodeChildren``
/// to avoid leaking the selected backend into ``View`` implementations (which would be
/// an annoying complexity for users of the library and it worth the slight sacrifice
/// in performance and strong-typing). The user never sees such type-erased wrappers.
@MainActor
public class AnyViewGraphNode<NodeView: View> {
    /// The node getting wrapped.
    public var node: Any

    /// The node's widget (type-erased).
    public var widget: AnyWidget {
        _getWidget()
    }

    /// The node's last proposed size.
    public var lastProposedSize: ProposedViewSize {
        _getLastProposedSize()
    }

    /// The node's type-erased layout computing method.
    private var _computeLayoutWithNewView:
        (
            _ newView: NodeView?,
            _ proposedSize: ProposedViewSize,
            _ environment: EnvironmentValues
        ) -> ViewLayoutResult
    /// The node's type-erased commit method.
    private var _commit: () -> ViewLayoutResult
    /// The type-erased getter for the node's widget.
    private var _getWidget: () -> AnyWidget
    /// The type-erased getter for the node's view.
    private var _getNodeView: () -> NodeView
    /// The type-erased getter for the node's children.
    private var _getNodeChildren: () -> any ViewGraphNodeChildren
    /// The type-erased getter for the node's underlying erased backend.
    private var _getBackend: () -> any BaseAppBackend
    /// The type-erased getter for the node's last proposed size.
    private var _getLastProposedSize: () -> ProposedViewSize

    /// Type-erases a view graph node.
    public init<Backend: BaseAppBackend>(_ node: ViewGraphNode<NodeView, Backend>) {
        self.node = node
        _computeLayoutWithNewView = node.computeLayout(with:proposedSize:environment:)
        _commit = node.commit
        _getWidget = {
            AnyWidget(node.widget)
        }
        _getNodeView = {
            node.view
        }
        _getNodeChildren = {
            node.children
        }
        _getBackend = {
            node.backend
        }
        _getLastProposedSize = {
            node.lastProposedSize
        }
    }

    /// Creates a new view graph node and immediately type-erases it.
    public convenience init<Backend: BaseAppBackend>(
        for view: NodeView,
        backend: Backend,
        snapshot: ViewGraphSnapshotter.NodeSnapshot? = nil,
        environment: EnvironmentValues
    ) {
        self.init(
            ViewGraphNode(
                for: view,
                backend: backend,
                snapshot: snapshot,
                environment: environment
            )
        )
    }

    /// Computes a view's layout. Propagates to the view's children unless
    /// the given size proposal already has a cached result.
    ///
    /// - Parameters:
    ///   - newView: The recomputed view.
    ///   - proposedSize: The view's proposed size.
    ///   - environment: The current environment.
    /// - Returns: The result of computing the view's layout.
    public func computeLayout(
        with newView: NodeView?,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues
    ) -> ViewLayoutResult {
        _computeLayoutWithNewView(newView, proposedSize, environment)
    }

    /// Commits the view's most recently computed layout. Propagates to the
    /// view's children. Also commits any view state changes.
    public func commit() -> ViewLayoutResult {
        _commit()
    }

    /// Gets the node's wrapped view.
    ///
    /// - Returns: The node's wrapped view.
    public func getView() -> NodeView {
        _getNodeView()
    }

    /// Gets the node's children.
    ///
    /// - Returns: The node's children.
    public func getChildren() -> any ViewGraphNodeChildren {
        _getNodeChildren()
    }

    /// Gets the node's backend.
    ///
    /// - Returns: The node's backend.
    public func getBackend() -> any BaseAppBackend {
        _getBackend()
    }

    /// Converts the node back to its original type. Crashes if the requested backend doesn't
    /// match the node's original backend.
    public func concreteNode<Backend: BaseAppBackend>(
        for backend: Backend.Type
    ) -> ViewGraphNode<NodeView, Backend> {
        guard let node = node as? ViewGraphNode<NodeView, Backend> else {
            fatalError("AnyViewGraphNode used with incompatible backend \(backend)")
        }
        return node
    }
}
