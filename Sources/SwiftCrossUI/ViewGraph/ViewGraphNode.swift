import Foundation

/// A view graph node storing a view, its widget, and its children (likely a
/// collection of more nodes).
///
/// This is where updates are initiated when a view's state updates, and where state is persisted
/// even when a view gets recomputed by its parent.
@MainActor
public class ViewGraphNode<NodeView: View, Backend: AppBackend>: Sendable {
    /// The view's single widget for the entirety of its lifetime in the view graph.
    ///
    public var widget: Backend.Widget {
        _widget!
    }
    /// Only optional because of some initialisation order requirements. Private and wrapped to
    /// hide this inconvenient detail.
    private var _widget: Backend.Widget?
    /// The view's children (usually just contains more view graph nodes, but can handle extra logic
    /// such as figuring out how to update variable length array of children efficiently).
    ///
    /// It's type-erased because otherwise complex implementation details would
    /// be forced to the user or other compromises would have to be made. I
    /// believe that this is the best option with Swift's current generics landscape.
    public var children: any ViewGraphNodeChildren {
        get {
            _children!
        }
        set {
            _children = newValue
        }
    }
    /// Only optional because of some initialisation order requirements. Private and wrapped to
    /// hide this inconvenient detail.
    private var _children: (any ViewGraphNodeChildren)?
    /// A copy of the view itself (from the latest computed body of its parent).
    public var view: NodeView
    /// The backend used to create the view's widget.
    public var backend: Backend

    /// The view's most recently computed layout. Doesn't include cached layouts,
    /// as this is the layout that is currently 'ready to commit'.
    public var currentLayout: ViewLayoutResult?
    /// A cache of update results keyed by the proposed size they were for. Gets
    /// cleared before the results' sizes become invalid.
    var resultCache: [ProposedViewSize: ViewLayoutResult]
    /// The most recent size proposed by the parent view. Used when updating the wrapped
    /// view as a result of a state change rather than the parent view updating. Proposals
    /// that get cached responses don't update this size, as this size should stay in sync
    /// with currentLayout.
    private(set) var lastProposedSize: ProposedViewSize
    /// Whether the widget has had its first update yet.
    private var hasHadFirstUpdate = false

    /// A cancellable handle to the view's state property observations.
    private var cancellables: [Cancellable]

    /// The environment most recently provided by this node's parent.
    private var parentEnvironment: EnvironmentValues

    /// The dynamic property updater for this view.
    private var dynamicPropertyUpdater: DynamicPropertyUpdater<NodeView>

    /// Creates a node for a given view while also creating the nodes for its children, creating
    /// the view's widget, and starting to observe its state for changes.
    public init(
        for nodeView: NodeView,
        backend: Backend,
        snapshot: ViewGraphSnapshotter.NodeSnapshot? = nil,
        environment: EnvironmentValues
    ) {
        self.backend = backend

        // Restore node snapshot if present.
        self.view = nodeView
        snapshot?.restore(to: view)

        // First create the view's child nodes and widgets
        let childSnapshots =
            snapshot?.isValid(for: NodeView.self) == true
            ? snapshot?.children : snapshot.map { [$0] }

        currentLayout = nil
        resultCache = [:]
        lastProposedSize = .zero
        parentEnvironment = environment
        cancellables = []

        let mirror = Mirror(reflecting: view)
        dynamicPropertyUpdater = DynamicPropertyUpdater(for: view, mirror: mirror)

        let viewEnvironment = updateEnvironment(environment)

        dynamicPropertyUpdater.update(view, with: viewEnvironment, previousValue: nil)

        let children = view.children(
            backend: backend,
            snapshots: childSnapshots,
            environment: viewEnvironment
        )
        self.children = children

        // Then create the widget for the view itself
        let widget = view.asWidget(
            children,
            backend: backend
        )
        _widget = widget

        let tag = String(String(describing: NodeView.self).split(separator: "<")[0])
        backend.tag(widget: widget, as: tag)

        // Update the view and its children when state changes (children are always updated first).
        for property in mirror.children {
            if property.label == "state" && property.value is ObservableObject {
                logger.warning(
                    """
                    the View.state protocol requirement has been removed in favour of \
                    SwiftUI-style @State annotations; decorate \(NodeView.self).state \
                    with the @State property wrapper to restore previous behaviour
                    """
                )
            }

            guard let value = property.value as? any ObservableProperty else {
                continue
            }

            cancellables.append(
                value.didChange
                    .observeAsUIUpdater(backend: backend) { [weak self] in
                        guard let self else { return }
                        self.bottomUpUpdate()
                    }
            )
        }
    }

    /// Triggers the view to be updated as part of a bottom-up chain of updates (where either the
    /// current view gets updated due to a state change and has potential to trigger its parent to
    /// update as well, or the current view's child has propagated such an update upwards).
    private func bottomUpUpdate() {
        // First we compute what size the view will be after the update. If it will change size,
        // propagate the update to this node's parent instead of updating straight away.
        let currentSize = currentLayout?.size
        let newLayout = self.computeLayout(
            proposedSize: lastProposedSize,
            environment: parentEnvironment
        )

        self.currentLayout = newLayout
        if newLayout.size != currentSize {
            resultCache[lastProposedSize] = newLayout
            parentEnvironment.onResize(newLayout.size)
        } else {
            _ = self.commit()
        }
    }

    private func updateEnvironment(_ environment: EnvironmentValues) -> EnvironmentValues {
        environment.with(\.onResize) { [weak self] _ in
            guard let self else { return }
            self.bottomUpUpdate()
        }
    }

    /// Recomputes the view's body and computes its layout and the layout of
    /// its children.
    ///
    /// The view may or may not propagate the update to its children depending
    /// on the nature of the update. If `newView` is provided (in the case that
    /// the parent's body got updated) then it simply replaces the old view
    /// while inheriting the old view's state.
    ///
    /// - Parameters:
    ///   - newView: The recomputed view.
    ///   - proposedSize: The view's proposed size.
    ///   - environment: The current environment.
    /// - Returns: The result of laying out the view.
    public func computeLayout(
        with newView: NodeView? = nil,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues
    ) -> ViewLayoutResult {
        // Defensively ensure that all future scene implementations obey this
        // precondition. By putting the check here instead of only in views
        // that require `environment.window` (such as the alert modifier view),
        // we decrease the likelihood of a bug like this flying under the radar.
        precondition(
            environment.window != nil,
            "View graph updated without parent window present in environment"
        )

        if !hasHadFirstUpdate {
            // We show the widget here instead of in init, because in init the widget
            // hasn't been added to its parent widget yet.
            backend.show(widget: widget)
            hasHadFirstUpdate = true
        }

        if proposedSize == lastProposedSize && !resultCache.isEmpty
            && (!parentEnvironment.allowLayoutCaching || environment.allowLayoutCaching),
            let currentLayout
        {
            // If the previous proposal is the same as the current one, and our
            // cache hasn't been invalidated, then we can reuse the current layout.
            // But only if the previous layout was computed without caching, or the
            // current layout is being computed with caching, cause otherwise we could
            // end up using a layout computed with caching while computing a layout
            // without caching.
            return currentLayout
        } else if environment.allowLayoutCaching, let cachedResult = resultCache[proposedSize] {
            // If this layout pass is a probing pass (not a final pass), then we
            // can reuse any layouts that we've computed since the cache was last
            // cleared. The cache gets cleared on commit.
            return cachedResult
        }

        parentEnvironment = environment
        lastProposedSize = proposedSize

        let previousView: NodeView?
        if let newView {
            previousView = view
            view = newView
        } else {
            previousView = nil
        }

        let viewEnvironment = updateEnvironment(environment)

        dynamicPropertyUpdater.update(view, with: viewEnvironment, previousValue: previousView)

        let result = view.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: viewEnvironment,
            backend: backend
        )

        // We assume that the view's sizing behaviour won't change between consecutive
        // layout computations and the following commit, because groups of updates
        // following that pattern are assumed to be occurring within a single overarching
        // view update. Under that assumption, we can cache view layout results.
        resultCache[proposedSize] = result

        currentLayout = result
        return result
    }

    /// Commits the view's most recently computed layout and any view state changes
    /// that have occurred since the last update (e.g. text content changes or font
    /// size changes).
    ///
    /// - Returns: The most recently computed layout. Guaranteed to match the
    ///   result of the last call to ``computeLayout(with:proposedSize:environment:)``.
    public func commit() -> ViewLayoutResult {
        guard let currentLayout else {
            logger.warning("layout committed before being computed, ignoring")
            return .leafView(size: .zero)
        }

        if parentEnvironment.allowLayoutCaching {
            logger.warning(
                "committing layout computed with caching enabled; results may be invalid",
                metadata: ["NodeView": "\(NodeView.self)"]
            )
        }
        if currentLayout.size.height == .infinity || currentLayout.size.width == .infinity {
            logger.warning(
                "infinite height or width on commit",
                metadata: [
                    "NodeView": "\(NodeView.self)",
                    "currentLayout.size": "\(currentLayout.size)",
                    "lastProposedSize": "\(lastProposedSize)",
                ]
            )
        }

        view.commit(
            widget,
            children: children,
            layout: currentLayout,
            environment: parentEnvironment,
            backend: backend
        )
        resultCache = [:]

        backend.showUpdate(of: widget)

        return currentLayout
    }
}
