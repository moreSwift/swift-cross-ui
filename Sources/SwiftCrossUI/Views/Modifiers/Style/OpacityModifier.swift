extension View {
    public func opacity(_ opacity: Double) -> some View {
        OpacityModifier(self, opacity: opacity)
    }
}

struct OpacityModifier<Child: View>: View {
    var body: TupleView1<Child>
    let opacity: Double
    
    init(_ child: Child, opacity: Double) {
        self.body = TupleView1(child)
        self.opacity = opacity
    }
    
    @CastBackend<BackendFeatures.ViewOpacity>(backendGenericName: "NewBackend")
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let result = body.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
        
        backend.setOpacity(of: widget, to: opacity)
        
        return result
    }
}
