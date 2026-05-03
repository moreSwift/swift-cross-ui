extension View {
    /// Adds an action to be performed when this view gets committed. Currently
    /// the action gets called before the view gets committed.
    ///
    /// - Parameter action: The action to perform when this view gets committed.
    func onCommit(perform action: @escaping @MainActor () -> Void) -> some View {
        OnCommitModifier(body: TupleView1(self), action: action)
    }
}

struct OnCommitModifier<Content: View>: View {
    var body: TupleView1<Content>
    var action: @MainActor () -> Void

    func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        action()
        return defaultAsWidget(children, backend: backend)
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        action()
        return defaultCommit(
            widget,
            children: children,
            layout: layout,
            environment: environment,
            backend: backend
        )
    }
}
