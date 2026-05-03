/// A view that can be rendered by any backend.
@MainActor
public protocol View {
    /// The view's content (composed of other views).
    associatedtype Content: View

    /// The view's contents.
    @ViewBuilder var body: Content { get }

    /// Gets the view's children as a type-erased collection of view graph
    /// nodes.
    ///
    /// The collection is type-erased to avoid leaking complex requirements to
    /// users implementing their own regular views.
    ///
    /// - Parameters:
    ///   - backend: The app's backend.
    ///   - snapshots: A list of snapshots, used to restore view state during a
    ///     hot reload.
    ///   - environment: The current environment.
    /// - Returns: The view's children as a type-erased collection of view graph
    ///   nodes.
    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren

    // TODO: Perhaps this can be split off into a separate protocol for the `TupleViewN`s
    //   if we can set up the generics right for VStack.
    /// Gets the view's children in a format that can be consumed by the
    /// ``LayoutSystem``.
    ///
    /// This really only needs to be its own method for views such as ``VStack``
    /// which treat their child's children as their own and skip over their
    /// direct child. Only needs to be implemented by the `TupleViewN`s.
    ///
    /// - Parameters:
    ///   - backend: The app's backend.
    ///   - children: The view's children.
    /// - Returns: The view's children in a format that can be consumed by the
    /// ``LayoutSystem``.
    func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild]

    /// Creates the view's widget using the supplied backend.
    ///
    /// A view is represented by the same widget instance for the whole time
    /// that it's visible even if its content is changing; keep that in mind
    /// while deciding the structure of the widget. For example, a view
    /// displaying one of two children should use ``BackendFeatures/GenericContainers/createContainer()``
    /// to create a container for the displayed child instead of just directly
    /// returning the widget of the currently displayed child (which would
    /// result in you not being able to ever switch to displaying the other
    /// child). This constraint significantly simplifies view implementations
    /// without requiring widgets to be re-created after every single update.
    ///
    /// - Parameters:
    ///   - children: The view's children.
    ///   - backend: The app's backend.
    /// - Returns: The view's widget created using the given backend.
    func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget

    /// Computes this view's layout after a state change or a change in
    /// available space.
    ///
    /// This method should _not_ apply the layout to `widget`; that should be
    /// done in ``commit(_:children:layout:environment:backend:)`` instead.
    ///
    /// `proposedSize` is the size suggested by the parent container, but child
    /// views always get the final call on their own size.
    ///
    /// - Parameters:
    ///   - widget: The view's underlying widget.
    ///   - children: The view's children.
    ///   - proposedSize: The size suggested to the view by its parent
    ///     container.
    ///   - environment: The current environment.
    ///   - backend: The app's backend.
    /// - Returns: The view's computed size, along with any propagated
    ///   preferences.
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult

    /// Commits the last computed layout to the underlying widget hierarchy.
    ///
    /// - Parameters:
    ///   - widget: The view's underlying widget.
    ///   - children: The view's children.
    ///   - layout: The layout to use for the view. Guaranteed to be the
    ///     last value returned by
    ///     ``computeLayout(_:children:proposedSize:environment:backend:)``.
    ///   - environment: The current environment.
    ///   - backend: The app's backend.
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    )
}

extension View {
    public func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        defaultChildren(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    /// The default `View.children` implementation. Haters may see this as a
    /// composition lover re-implementing inheritance; I see it as innovation.
    public func defaultChildren<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    public func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        defaultLayoutableChildren(backend: backend, children: children)
    }

    /// The default `View.layoutableChildren` implementation. Haters may see
    /// this as a composition lover re-implementing inheritance; I see it as
    /// innovation.
    public func defaultLayoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        body.layoutableChildren(backend: backend, children: children)
    }

    public func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        defaultAsWidget(children, backend: backend)
    }

    /// The default `View.asWidget` implementation. Haters may see this as a
    /// composition lover re-implementing inheritance; I see it as innovation.
    public func defaultAsWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let vStack = VStack(content: body)
        return vStack.asWidget(children, backend: backend)
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        defaultComputeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
    }

    /// The default `View.computeLayout` implementation. Haters may see this as a
    /// composition lover re-implementing inheritance; I see it as innovation.
    public func defaultComputeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let vStack = VStack(content: body)
        return vStack.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
    }

    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        defaultCommit(
            widget,
            children: children,
            layout: layout,
            environment: environment,
            backend: backend
        )
    }

    public func defaultCommit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let vStack = VStack(content: body)
        return vStack.commit(
            widget,
            children: children,
            layout: layout,
            environment: environment,
            backend: backend
        )
    }
}
