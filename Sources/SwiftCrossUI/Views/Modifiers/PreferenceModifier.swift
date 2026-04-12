extension View {
    public func preference<V>(
        key: WritableKeyPath<PreferenceValues, V>,
        value: V
    ) -> some View {
        PreferenceModifier(self) { preferences, _ in
            var preferences = preferences
            preferences[keyPath: key] = value
            return preferences
        }
    }
}

struct PreferenceModifier<Child: View>: View {
    var body: TupleView1<Child>
    var modification: (PreferenceValues, EnvironmentValues) -> PreferenceValues

    init(
        _ child: Child,
        modification: @escaping (PreferenceValues, EnvironmentValues) -> PreferenceValues
    ) {
        self.body = TupleView1(child)
        self.modification = modification
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var result = body.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
        result.preferences = modification(result.preferences, environment)
        return result
    }

    func commit<Backend: BaseAppBackend>(
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
            environment: environment,
            backend: backend
        )
    }
}
