/// A view that arranges its subviews vertically.
public struct VStack<Content: View>: View {
    static var defaultSpacing: Int { 10 }

    public var body: Content

    /// The amount of spacing to apply between children.
    private var spacing: Int
    /// The alignment of the stack's children in the horizontal direction.
    private var alignment: HorizontalAlignment

    /// Creates a vertical stack with the given spacing and alignment.
    ///
    /// - Parameters:
    ///   - alignment: The alignment of the stack's children in the horizontal
    ///     direction.
    ///   - spacing: The amount of spacing to apply between children.
    ///   - content: The content of the stack.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Int? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: spacing, content: content())
    }

    /// Creates a vertical stack with the given spacing and alignment.
    ///
    /// - Parameters:
    ///   - alignment: The alignment of the stack's children in the horizontal
    ///     direction.
    ///   - spacing: The amount of spacing to apply between children.
    ///   - content: The content of the stack.
    init(
        alignment: HorizontalAlignment = .center,
        spacing: Int? = nil,
        content: Content
    ) {
        body = content
        self.spacing = spacing ?? Self.defaultSpacing
        self.alignment = alignment
    }

    public func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let vStack = backend.createContainer()
        for (index, child) in children.widgets(for: backend).enumerated() {
            backend.insert(child, into: vStack, at: index)
        }
        return vStack
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        if !(children is TupleViewChildren || children is EmptyViewChildren) {
            // TODO: Make layout caching a ViewGraphNode feature so that we can handle
            //   these edge cases without a second thought. Would also make introducing
            //   a port of SwiftUI's Layout protocol much easier.
            logger.warning(
                "VStack will not function correctly with non-TupleView content",
                metadata: [
                    "childrenType": "\(type(of: children))",
                    "contentType": "\(Content.self)",
                ]
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
                .with(\.layoutOrientation, .vertical)
                .with(\.layoutAlignment, alignment.asStackAlignment)
                .with(\.layoutSpacing, spacing),
            backend: backend
        )
        (children as? TupleViewChildren)?.stackLayoutCache = cache
        return result
    }

    public func commit<Backend: BaseAppBackend>(
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
                .with(\.layoutOrientation, .vertical)
                .with(\.layoutAlignment, alignment.asStackAlignment)
                .with(\.layoutSpacing, spacing),
            backend: backend
        )
        (children as? TupleViewChildren)?.stackLayoutCache = cache
    }
}
