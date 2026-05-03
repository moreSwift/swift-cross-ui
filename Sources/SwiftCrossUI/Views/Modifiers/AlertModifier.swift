extension View {
    public func alert(
        _ title: String,
        isPresented: Binding<Bool>,
        @AlertActionsBuilder actions: () -> [AlertAction]
    ) -> some View {
        AlertModifierView(
            child: self,
            title: title,
            isPresented: isPresented,
            actions: actions()
        )
    }

    public func alert(
        _ title: Binding<String?>,
        @AlertActionsBuilder actions: () -> [AlertAction]
    ) -> some View {
        AlertModifierView(
            child: self,
            title: title.wrappedValue ?? "",
            isPresented: Binding {
                title.wrappedValue != nil
            } set: { newValue in
                if !newValue {
                    title.wrappedValue = nil
                }
            },
            actions: actions()
        )
    }
}

struct AlertModifierView<Child: View>: TypeSafeView {
    typealias Children = AlertModifierViewChildren<Child>

    var body = EmptyView()

    var child: Child
    var title: String
    var isPresented: Binding<Bool>
    var actions: [AlertAction]

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        AlertModifierViewChildren(
            childNode: AnyViewGraphNode(
                ViewGraphNode(
                    for: child,
                    backend: backend,
                    environment: environment
                )
            ),
            alert: nil
        )
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        children.childNode.widget.into()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.childNode.computeLayout(
            with: child,
            proposedSize: proposedSize,
            environment: environment
        )
    }

    @CastBackend<BackendFeatures.Alerts>(backendGenericName: "NewBackend")
    func commit<Backend: BaseAppBackend>(
        _: Backend.Widget,
        children: AlertModifierViewChildren<Child>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        _ = children.childNode.commit()

        if isPresented.wrappedValue && children.alert == nil {
            let alert = backend.createAlert()
            backend.updateAlert(
                alert,
                title: title,
                actionLabels: actions.map(\.label),
                environment: environment
            )
            backend.showAlert(
                alert,
                window: .some(environment.window! as! NewBackend.Window)
            ) { responseId in
                children.alert = nil
                isPresented.wrappedValue = false
                actions[responseId].action()
            }
            children.alert = alert
        } else if isPresented.wrappedValue == false && children.alert != nil {
            backend.dismissAlert(
                children.alert as! NewBackend.Alert,
                window: .some(environment.window! as! NewBackend.Window)
            )
            children.alert = nil
        }
    }
}

class AlertModifierViewChildren<Child: View>: ViewGraphNodeChildren {
    var childNode: AnyViewGraphNode<Child>
    var alert: Any?

    var widgets: [AnyWidget] {
        [childNode.widget]
    }

    var erasedNodes: [ErasedViewGraphNode] {
        [ErasedViewGraphNode(wrapping: childNode)]
    }

    init(
        childNode: AnyViewGraphNode<Child>,
        alert: Any?
    ) {
        self.childNode = childNode
        self.alert = alert
    }
}
