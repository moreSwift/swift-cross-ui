/// A view that arranges its subviews horizontally.
public struct HStack<Content: View>: View {
    public var body: Content

    /// The amount of spacing to apply between children.
    private var spacing: Int
    /// The alignment of the stack's children in the vertical direction.
    private var alignment: VerticalAlignment

    /// Creates a horizontal stack with the given spacing and alignment.
    ///
    /// - Parameters:
    ///   - alignment: The alignment of the stack's children in the vertical
    ///     direction.
    ///   - spacing: The amount of spacing to apply between children.
    ///   - content: The content of the stack.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int? = nil,
        @ViewBuilder _ content: () -> Content
    ) {
        body = content()
        self.spacing = spacing ?? VStack<EmptyView>.defaultSpacing
        self.alignment = alignment
    }

    public func asWidget<Backend: AppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let hStack = backend.createContainer()
        for (index, child) in children.widgets(for: backend).enumerated() {
            backend.insert(child, into: hStack, at: index)
        }
        return hStack
    }

    public func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        if !(children is TupleViewChildren || children is EmptyViewChildren) {
            logger.warning(
                "HStack will not function correctly with non-TupleView content",
                metadata: ["childrenType": "\(type(of: children))"]
            )
        }
        var cache = (children as? TupleViewChildren)?.stackLayoutCache ?? StackLayoutCache.initial
        let result = LayoutSystem.computeStackLayout(
            container: widget,
            children: layoutableChildren(backend: backend, children: children),
            cache: &cache,
            proposedSize: proposedSize,
            environment:
                environment
                .with(\.layoutOrientation, .horizontal)
                .with(\.layoutAlignment, alignment.asStackAlignment)
                .with(\.layoutSpacing, spacing),
            backend: backend
        )
        (children as? TupleViewChildren)?.stackLayoutCache = cache
        return result
    }

    public func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        var cache = (children as? TupleViewChildren)?.stackLayoutCache ?? StackLayoutCache.initial
        LayoutSystem.commitStackLayout(
            container: widget,
            children: layoutableChildren(backend: backend, children: children),
            cache: &cache,
            layout: layout,
            environment:
                environment
                .with(\.layoutOrientation, .horizontal)
                .with(\.layoutAlignment, alignment.asStackAlignment)
                .with(\.layoutSpacing, spacing),
            backend: backend
        )
        (children as? TupleViewChildren)?.stackLayoutCache = cache
    }
}
