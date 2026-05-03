/// A container view that allows its content to read the size proposed to it.
///
/// Geometry readers always take up the size proposed to them; no more, no less.
/// This is to decouple the geometry reader's size from the size of its content
/// in order to avoid feedback loops.
///
/// ```swift
/// struct MeasurementView: View {
///     var body: some View {
///         GeometryReader { proxy in
///             Text("Width: \(proxy.size.x)")
///             Text("Height: \(proxy.size.y)")
///         }
///     }
/// }
/// ```
///
/// > Note: Geometry reader content may get evaluated multiple times with various
/// > sizes before the layout system settles on a size. Do not depend on the size
/// > proposal always being final.
public struct GeometryReader<Content: View>: TypeSafeView, View {
    var content: (GeometryProxy) -> Content

    public var body = EmptyView()

    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> GeometryReaderChildren<Content> {
        GeometryReaderChildren()
    }

    func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: GeometryReaderChildren<Content>
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: GeometryReaderChildren<Content>,
        backend: Backend
    ) -> Backend.Widget {
        // This is a little different to our usual wrapper implementations
        // because we want to avoid calling the user's content closure before
        // we actually have to.
        return backend.createContainer()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ container: Backend.Widget,
        children: GeometryReaderChildren<Content>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let size = proposedSize.replacingUnspecifiedDimensions(by: ViewSize(10, 10))
        let view = content(GeometryProxy(size: size))

        let environment = environment.with(\.layoutAlignment, .leading)

        let contentNode: AnyViewGraphNode<Content>
        if let node = children.node {
            contentNode = node
        } else {
            contentNode = AnyViewGraphNode(
                for: view,
                backend: backend,
                environment: environment
            )
            children.node = contentNode

            backend.insert(contentNode.widget.into(), into: container, at: 0)
        }

        let contentResult = contentNode.computeLayout(
            with: view,
            proposedSize: ProposedViewSize(size),
            environment: environment
        )

        return ViewLayoutResult(
            size: size,
            childResults: [contentResult]
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: GeometryReaderChildren<Content>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        _ = children.node?.commit()
        backend.setPosition(ofChildAt: 0, in: widget, to: .zero)
        backend.setSize(of: widget, to: layout.size.vector)
    }
}

class GeometryReaderChildren<Content: View>: ViewGraphNodeChildren {
    var node: AnyViewGraphNode<Content>?

    var widgets: [AnyWidget] {
        [node?.widget].compactMap { $0 }
    }

    var erasedNodes: [ErasedViewGraphNode] {
        [node.map(ErasedViewGraphNode.init(wrapping:))].compactMap { $0 }
    }
}
