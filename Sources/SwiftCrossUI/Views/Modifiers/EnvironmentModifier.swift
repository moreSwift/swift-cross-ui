package struct EnvironmentModifier<Child: View>: View {
    package var body: TupleView1<Child>
    var modification: (EnvironmentValues) -> EnvironmentValues

    package init(_ child: Child, modification: @escaping (EnvironmentValues) -> EnvironmentValues) {
        self.body = TupleView1(child)
        self.modification = modification
    }

    package func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: modification(environment)
        )
    }

    package func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        body.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: modification(environment),
            backend: backend
        )
    }

    package func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        body.commit(
            widget,
            children: children,
            layout: layout,
            environment: modification(environment),
            backend: backend
        )
    }
}

extension View {
    /// Modifies the environment of the View its applied to
    public func environment<T>(_ keyPath: WritableKeyPath<EnvironmentValues, T>, _ newValue: T)
        -> some View
    {
        EnvironmentModifier(self) { environment in
            environment.with(keyPath, newValue)
        }
    }

    /// Adds an observable object to the environment of the enclosed View.
    /// You are responsible for ensuring that the object is being observed
    /// by a parent view, as this modifier does not perform any observation.
    public func environment<T: ObservableObject>(_ object: T) -> some View {
        EnvironmentModifier(self) { environment in
            var environment = environment
            environment[observable: T.self] = object
            return environment
        }
    }
}
