import Foundation

/// A view graph node storing a view, its widget, and its children (likely a collection of more nodes).
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
    /// It's type-erased because otherwise complex implementation details would be forced to the user
    /// or other compromises would have to be made. I believe that this is the best option with Swift's
    /// current generics landscape.
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

    /// The most recent update result for the wrapped view.
    var currentResult: ViewUpdateResult?
    /// A cache of update results keyed by the proposed size they were for. Gets cleared before the
    /// results' sizes become invalid.
    var resultCache: [SIMD2<Int>: ViewUpdateResult]
    /// The most recent size proposed by the parent view. Used when updating the wrapped
    /// view as a result of a state change rather than the parent view updating.
    private var lastProposedSize: SIMD2<Int>

    /// A cancellable handle to the view's state property observations.
    private var cancellables: [Cancellable]

    /// The environment most recently provided by this node's parent.
    private var parentEnvironment: EnvironmentValues

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

        currentResult = nil
        resultCache = [:]
        lastProposedSize = .zero
        parentEnvironment = environment
        cancellables = []

        let viewEnvironment = updateEnvironment(environment)

        updateDynamicProperties(
            of: view,
            previousValue: nil,
            environment: viewEnvironment
        )

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
        let mirror = Mirror(reflecting: view)
        for property in mirror.children {
            if property.label == "state" && property.value is ObservableObject {
                print(
                    """

                    warning: The View.state protocol requirement has been removed in favour of
                             SwiftUI-style @State annotations. Decorate \(NodeView.self).state
                             with the @State property wrapper to restore previous behaviour.

                    """
                )
            }

            guard let value = property.value as? StateProperty else {
                continue
            }

            cancellables.append(
                value.didChange
                    .observeAsUIUpdater(backend: backend) { [weak self] in
                        guard let self = self else { return }
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
        let currentSize = currentResult?.size
        let newResult = self.update(
            proposedSize: lastProposedSize,
            environment: parentEnvironment,
            dryRun: true
        )

        if newResult.size != currentSize {
            self.currentResult = newResult
            resultCache[lastProposedSize] = newResult
            parentEnvironment.onResize(newResult.size)
        } else {
            let finalResult = self.update(
                proposedSize: lastProposedSize,
                environment: parentEnvironment,
                dryRun: false
            )
            if finalResult.size != newResult.size {
                print(
                    """
                    warning: State-triggered view update had mismatch \
                    between dry-run size and final size.
                          -> dry-run size: \(newResult.size)
                          -> final size:   \(finalResult.size)
                    """
                )
            }
            self.currentResult = finalResult
        }
    }

    private func updateEnvironment(_ environment: EnvironmentValues) -> EnvironmentValues {
        var newEnvironment = environment

        // Strong capture of self (no weak)
        newEnvironment.onResize = { newSize in
            self.bottomUpUpdate()
        }

        return newEnvironment
    }



    /// Recomputes the view's body, and updates its widget accordingly. The view may or may not
    /// propagate the update to its children depending on the nature of the update. If `newView`
    /// is provided (in the case that the parent's body got updated) then it simply replaces the
    /// old view while inheriting the old view's state.
    /// - Parameter dryRun: If `true`, only compute sizing and don't update the underlying widget.
    public func update(
        with newView: NodeView? = nil,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        dryRun: Bool
    ) -> ViewUpdateResult {
        // Defensively ensure that all future scene implementations obey this
        // precondition. By putting the check here instead of only in views
        // that require `environment.window` (such as the alert modifier view),
        // we decrease the likelihood of a bug like this flying under the radar.
        precondition(
            environment.window != nil,
            "View graph updated without parent window present in environment"
        )

        if dryRun, let cachedResult = resultCache[proposedSize] {
            return cachedResult
        }

        // Attempt to cleverly reuse the current size if we can know that it
        // won't change. We must of course be in a dry run, have a known
        // current size, and must've run at least one proper dry run update
        // since the last update cycle (checked via`!sizeCache.isEmpty`) to
        // ensure that the view has been updated at least once with the
        // current view state.
        if dryRun, let currentResult, !resultCache.isEmpty {
            // If both the previous and current proposed sizes are larger than
            // the view's previously computed maximum size, reuse the previous
            // result (currentResult).
            if ((Double(lastProposedSize.x) >= currentResult.size.maximumWidth
                && Double(proposedSize.x) >= currentResult.size.maximumWidth)
                || proposedSize.x == lastProposedSize.x)
                && ((Double(lastProposedSize.y) >= currentResult.size.maximumHeight
                    && Double(proposedSize.y) >= currentResult.size.maximumHeight)
                    || proposedSize.y == lastProposedSize.y)
            {
                return currentResult
            }

            // If the view has already been updated this update cycle and claims
            // to be fixed size (maximumSize == minimumSize) then reuse the current
            // result.
            let maximumSize = SIMD2(
                currentResult.size.maximumWidth,
                currentResult.size.maximumHeight
            )
            let minimumSize = SIMD2(
                Double(currentResult.size.minimumWidth),
                Double(currentResult.size.minimumHeight)
            )
            if maximumSize == minimumSize {
                return currentResult
            }
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

        updateDynamicProperties(
            of: view,
            previousValue: previousView,
            environment: viewEnvironment
        )

        if !dryRun {
            backend.show(widget: widget)
        }
        let result = view.update(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: viewEnvironment,
            backend: backend,
            dryRun: dryRun
        )

        // We assume that the view's sizing behaviour won't change between consecutive dry run updates
        // and the following real update because groups of updates following that pattern are assumed to
        // be occurring within a single overarching view update. It may seem weird that we set it
        // to false after real updates, but that's because it may get invalidated between a real
        // update and the next dry-run update.
        if !dryRun {
            resultCache = [:]
        } else {
            resultCache[proposedSize] = result
        }

        currentResult = result
        return result
    }
}
