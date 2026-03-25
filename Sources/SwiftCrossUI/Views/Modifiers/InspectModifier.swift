/// A point at which a view's underlying widget can be inspected.
public struct InspectionPoints: OptionSet, RawRepresentable, Hashable, Sendable {
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let onCreate = Self(rawValue: 1 << 0)
    public static let beforeUpdate = Self(rawValue: 1 << 1)
    public static let afterUpdate = Self(rawValue: 1 << 2)
}

/// The `View.inspect(_:_:)` family of modifiers is implemented within each
/// backend. Make sure to import your chosen backend in any files where you
/// need to inspect a widget. This type simply supports the implementation of
/// those backend-specific modifiers.
package struct InspectView<Child: View> {
    var child: Child
    var inspectionPoints: InspectionPoints
    var action: @MainActor (_ widget: AnyWidget, _ children: any ViewGraphNodeChildren) -> Void

    package init<WidgetType>(
        child: Child,
        inspectionPoints: InspectionPoints,
        action: @escaping @MainActor @Sendable (WidgetType) -> Void
    ) {
        self.child = child
        self.inspectionPoints = inspectionPoints
        self.action = { widget, _ in
            action(widget.into())
        }
    }

    package init<WidgetType, Children: ViewGraphNodeChildren>(
        child: Child,
        inspectionPoints: InspectionPoints,
        action: @escaping @MainActor @Sendable (WidgetType, Children) -> Void
    ) {
        self.child = child
        self.inspectionPoints = inspectionPoints
        self.action = { widget, children in
            action(widget.into(), children as! Children)
        }
    }
}

extension InspectView: View {
    package var body: some View { EmptyView() }

    package func asWidget<Backend: AppBackend.Base>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let widget = child.asWidget(children, backend: backend)
        if inspectionPoints.contains(.onCreate) {
            action(AnyWidget(widget), children)
        }
        return widget
    }

    package func children<Backend: AppBackend.Base>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        child.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    package func layoutableChildren<Backend: AppBackend.Base>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        child.layoutableChildren(backend: backend, children: children)
    }

    package func computeLayout<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        if inspectionPoints.contains(.beforeUpdate) {
            action(AnyWidget(widget), children)
        }
        let result = child.computeLayout(
            widget,
            children: children,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
        return result
    }

    package func commit<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        child.commit(
            widget,
            children: children,
            layout: layout,
            environment: environment,
            backend: backend
        )
        if inspectionPoints.contains(.afterUpdate) {
            action(AnyWidget(widget), children)
        }
    }
}
