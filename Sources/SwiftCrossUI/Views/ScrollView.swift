import Foundation

/// A view that is scrollable when it would otherwise overflow available space.
///
/// Use the ``View/frame(width:height:alignment:)`` modifier to constrain width
/// or height if necessary.
public struct ScrollView<Content: View>: TypeSafeView, View {
    public var body: VStack<Content>
    public var axes: Axis.Set

    /// Wraps a view in a scrollable container.
    ///
    /// - Parameters:
    ///   - axes: The axes of to enable scrolling on. Defaults to
    ///     ``Axis/Set/vertical``.
    ///   - content: The content of the scroll view.
    public init(_ axes: Axis.Set = .vertical, @ViewBuilder _ content: () -> Content) {
        self.axes = axes
        body = VStack(content: content())
    }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> ScrollViewChildren<Content> {
        // TODO: Verify that snapshotting works correctly with this
        return ScrollViewChildren(
            wrapping: TupleViewChildren1(
                body,
                backend: backend,
                snapshots: snapshots,
                environment: environment
            ),
            backend: backend
        )
    }

    func layoutableChildren<Backend: AppBackend>(
        backend: Backend,
        children: TupleViewChildren1<VStack<Content>>
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    func asWidget<Backend: AppBackend>(
        _ children: ScrollViewChildren<Content>,
        backend: Backend
    ) -> Backend.Widget {
        return backend.createScrollContainer(for: children.innerContainer.into())
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: ScrollViewChildren<Content>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // If all scroll axes are unspecified, then our size is exactly that of
        // the child view. This includes when we have no scroll axes.
        let willEarlyExit = Axis.allCases.allSatisfy({ axis in
            !axes.contains(axis) || proposedSize[component: axis] == nil
        })

        // Probe how big the child would like to be
        var childProposal = proposedSize
        for axis in Axis.allCases where axes.contains(axis) {
            childProposal[component: axis] = nil
        }

        let childResult = children.child.computeLayout(
            with: body,
            proposedSize: childProposal,
            environment: environment.with(
                \.allowLayoutCaching,
                !willEarlyExit || environment.allowLayoutCaching
            )
        )

        if willEarlyExit {
            return childResult
        }

        let contentSize = childResult.size

        // An axis is present when it's a scroll axis AND the corresponding
        // child content size is bigger then the proposed size. If the proposed
        // size along the axis is nil then we don't have a scroll bar.
        let hasHorizontalScrollBar: Bool
        if axes.contains(.horizontal), let proposedWidth = proposedSize.width {
            hasHorizontalScrollBar = contentSize.width > proposedWidth
        } else {
            hasHorizontalScrollBar = false
        }
        children.hasHorizontalScrollBar = hasHorizontalScrollBar

        let hasVerticalScrollBar: Bool
        if axes.contains(.vertical), let proposedHeight = proposedSize.height {
            hasVerticalScrollBar = contentSize.height > proposedHeight
        } else {
            hasVerticalScrollBar = false
        }
        children.hasVerticalScrollBar = hasVerticalScrollBar

        let scrollBarWidth = Double(backend.scrollBarWidth)
        let verticalScrollBarWidth = hasVerticalScrollBar ? scrollBarWidth : 0
        let horizontalScrollBarHeight = hasHorizontalScrollBar ? scrollBarWidth : 0

        // Compute the final size to propose to the child view. Subtract off
        // scroll bar sizes from non-scrolling axes.
        var finalContentSizeProposal = childProposal
        if !axes.contains(.horizontal), let proposedWidth = childProposal.width {
            finalContentSizeProposal.width = proposedWidth - verticalScrollBarWidth
        }

        if !axes.contains(.vertical), let proposedHeight = childProposal.height {
            finalContentSizeProposal.height = proposedHeight - horizontalScrollBarHeight
        }

        // Propose a final size to the child view.
        let finalChildResult = children.child.computeLayout(
            with: nil,
            proposedSize: finalContentSizeProposal,
            environment: environment
        )

        // Compute the outer size.
        var outerSize = finalChildResult.size
        if axes.contains(.horizontal) {
            outerSize.width =
                proposedSize.width
                ?? (finalChildResult.size.width + verticalScrollBarWidth)
        } else {
            outerSize.width += verticalScrollBarWidth
        }

        if axes.contains(.vertical) {
            outerSize.height =
                proposedSize.height
                ?? (finalChildResult.size.height + horizontalScrollBarHeight)
        } else {
            outerSize.height += horizontalScrollBarHeight
        }

        return ViewLayoutResult(
            size: outerSize,
            childResults: [finalChildResult],
            participateInStackLayoutsWhenEmpty: true
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: ScrollViewChildren<Content>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let scrollViewSize = layout.size
        let finalContentSize = children.child.commit().size

        backend.setSize(of: widget, to: scrollViewSize.vector)
        backend.setSize(of: children.innerContainer.into(), to: finalContentSize.vector)
        backend.setPosition(ofChildAt: 0, in: children.innerContainer.into(), to: .zero)
        backend.updateScrollContainer(
            widget,
            environment: environment,
            bounceHorizontally: axes.contains(.horizontal),
            bounceVertically: axes.contains(.vertical),
            hasHorizontalScrollBar: children.hasHorizontalScrollBar,
            hasVerticalScrollBar: children.hasVerticalScrollBar
        )
    }
}

class ScrollViewChildren<Content: View>: ViewGraphNodeChildren {
    var children: TupleView1<VStack<Content>>.Children
    var innerContainer: AnyWidget

    var hasVerticalScrollBar = false
    var hasHorizontalScrollBar = false

    var child: AnyViewGraphNode<VStack<Content>> {
        children.child0
    }

    var widgets: [AnyWidget] {
        // The implementation of this property doesn't really matter. It doesn't
        // really have a reason to get used anywhere.
        children.widgets
    }

    var erasedNodes: [ErasedViewGraphNode] {
        children.erasedNodes
    }

    init<Backend: AppBackend>(
        wrapping children: TupleView1<VStack<Content>>.Children,
        backend: Backend
    ) {
        self.children = children
        let innerContainer = backend.createContainer()
        backend.insert(children.child0.widget.into(), into: innerContainer, at: 0)
        self.innerContainer = AnyWidget(innerContainer)
    }
}
