/// A container that lays its views on top of each other.
public struct ZStack<Content: View>: View {
    /// The stack's alignment.
    public var alignment: Alignment
    /// The stack's content.
    public var body: Content

    /// Creates a ``ZStack``.
    ///
    /// - Parameters:
    ///   - alignment: The stack's alignment.
    ///   - content: The stack's content.
    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            alignment: alignment,
            content: content()
        )
    }

    init(alignment: Alignment, content: Content) {
        self.alignment = alignment
        body = content
    }

    public func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let zStack = backend.createContainer()
        for (index, child) in children.widgets(for: backend).enumerated() {
            backend.insert(child, into: zStack, at: index)
        }
        return zStack
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let childResults = layoutableChildren(backend: backend, children: children)
            .map { child in
                child.computeLayout(
                    proposedSize: proposedSize,
                    environment: environment
                )
            }

        let size = ViewSize(
            childResults.map(\.size.width).max() ?? 0,
            childResults.map(\.size.height).max() ?? 0
        )

        if !(children is TupleViewChildren || children is EmptyViewChildren) {
            logger.warning(
                "ZStack will not function correctly with non-TupleView content",
                metadata: [
                    "childrenType": "\(type(of: children))",
                    "contentType": "\(Content.self)",
                ]
            )
        }

        (children as? TupleViewChildren)?.stackLayoutCache = StackLayoutCache(
            priorityGroups: [],
            isHidden: [],
            totalSpacing: 0,
            totalReservedSpace: 0,
            minimumLengths: [],
            redistributeSpaceOnCommit: proposedSize.width == nil || proposedSize.height == nil
        )

        return ViewLayoutResult(size: size, childResults: childResults)
    }

    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let cache = (children as? TupleViewChildren)?.stackLayoutCache ?? StackLayoutCache.initial
        let children = layoutableChildren(backend: backend, children: children)

        if cache.redistributeSpaceOnCommit {
            for child in children {
                _ = child.computeLayout(
                    proposedSize: ProposedViewSize(layout.size),
                    environment: environment
                )
            }
        }

        let size = layout.size
        let layoutResults = children.map { child in
            child.commit()
        }

        for (i, layoutResult) in layoutResults.enumerated() {
            let position = alignment.position(
                ofChild: layoutResult.size.vector,
                in: size.vector
            )
            backend.setPosition(ofChildAt: i, in: widget, to: position)
        }

        backend.setSize(of: widget, to: size.vector)
    }
}
