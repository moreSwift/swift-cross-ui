import Foundation

/// The root of the view graph which shadows a root view's structure with extra metadata,
/// cross-update state persistence, and behind the scenes backend widget handling.
///
/// This is where state updates are propagated through the view hierarchy, and also where view
/// bodies get recomputed. The root node is type-erased because otherwise the selected backend
/// would have to get propagated through the entire scene graph which would leak it into
/// ``Scene`` implementations (exposing users to unnecessary internal details).
@MainActor
public class ViewGraph<Root: View> {
    /// The view graph's
    public typealias RootNode = AnyViewGraphNode<Root>

    /// The root node storing the node for the root view's body.
    public var rootNode: RootNode
    /// A cancellable handle to observation of the view's state.
    private var cancellable: Cancellable?
    /// The root view being managed by this view graph.
    private var view: Root
    /// The latest size proposal.
    private var latestProposal: ProposedViewSize
    /// The latest proposal as of the last commit (used when updated the root
    /// view due to a state change as opposed to a window resizing event).
    private var committedProposal: ProposedViewSize
    /// The current size of the root view.
    private var currentRootViewResult: ViewLayoutResult

    /// The environment most recently provided by this node's parent scene.
    private var parentEnvironment: EnvironmentValues

    private var isFirstUpdate = true
    private var setIncomingURLHandler: ((@escaping (URL) -> Void) -> Void)?

    /// Creates a view graph for a root view with a specific backend.
    ///
    /// - Parameters:
    ///   - view: The root view to create a graph for.
    ///   - backend: The app's backend.
    ///   - environment: The current environment.
    public init<Backend: BaseAppBackend>(
        for view: Root,
        backend: Backend,
        environment: EnvironmentValues
    ) {
        rootNode = AnyViewGraphNode(for: view, backend: backend, environment: environment)

        self.view = view
        latestProposal = .zero
        committedProposal = .zero
        parentEnvironment = environment
        currentRootViewResult = ViewLayoutResult.leafView(size: .zero)
        setIncomingURLHandler =
            (backend as? any BackendFeatures.IncomingURLs)?.setIncomingURLHandler(to:)
    }

    /// Recomputes the entire UI (e.g. due to the root view's state updating).
    ///
    /// If the update is due to the parent scene getting updated then the view
    /// is recomputed and passed as `newView`.
    public func computeLayout(
        with newView: Root? = nil,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues
    ) -> ViewLayoutResult {
        parentEnvironment = environment
        latestProposal = proposedSize

        let result = rootNode.computeLayout(
            with: newView ?? view,
            proposedSize: proposedSize,
            environment: parentEnvironment
        )
        self.currentRootViewResult = result
        if let newView {
            self.view = newView
        }
        return result
    }

    /// Commits the result of the last computeLayout call to the underlying
    /// widget hierarchy.
    public func commit() {
        committedProposal = latestProposal
        self.currentRootViewResult = rootNode.commit()
        if isFirstUpdate {
            setIncomingURLHandler? { url in
                self.currentRootViewResult.preferences.onOpenURL?(url)
            }
            isFirstUpdate = false
        }
    }

    public func snapshot() -> ViewGraphSnapshotter.NodeSnapshot {
        ViewGraphSnapshotter.snapshot(of: rootNode)
    }
}
