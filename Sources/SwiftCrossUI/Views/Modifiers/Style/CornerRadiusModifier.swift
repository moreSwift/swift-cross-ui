extension View {
    public func cornerRadius(_ radius: Int) -> some View {
        CornerRadiusModifier(body: self, cornerRadius: radius)
    }
}

struct CornerRadiusModifier<Content: View>: View {
    var body: Content
    var cornerRadius: Int

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        body.asWidget(children, backend: backend)
    }

    func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        body.layoutableChildren(backend: backend, children: children)
    }

    func computeLayout<Backend: BaseAppBackend>(
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
            environment: environment,
            backend: backend
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        // We used to wrap the child content in a container and then set the corner
        // radius on that, since it was the simplest approach. But Gtk3Backend has
        // extremely poor corner radius support and only applies the corner radius
        // to the background of view with the corner radius property set. This means
        // that corner radii don't work in many cases with Gtk3Backend, but if we
        // implement the modifier this way then you can at the very least set the
        // cornerRadius of a coloured rectangle, which is quite a common thing to
        // want to do.
        body.commit(
            widget,
            children: children,
            layout: layout,
            environment: environment,
            backend: backend
        )

        guard let backend = backend as? any BackendFeatures.CornerRadius else {
            logger.warnOnce("\(Backend.self) doesn't support setting corner radii")
            return
        }

        setRadius(backend: backend)
        func setRadius<Backend2: BackendFeatures.CornerRadius>(backend: Backend2) {
            backend.setCornerRadius(of: widget as! Backend2.Widget, to: cornerRadius)
        }
    }
}
