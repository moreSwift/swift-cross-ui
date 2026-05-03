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
    var child: TupleView1<Child>
    var inspectionPoints: InspectionPoints
    var action: @MainActor (_ widget: AnyWidget, _ children: any ViewGraphNodeChildren) -> Void

    package init<WidgetType>(
        child: Child,
        inspectionPoints: InspectionPoints,
        action: @escaping @MainActor @Sendable (WidgetType) -> Void
    ) {
        self.child = TupleView1(child)
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
        self.child = TupleView1(child)
        self.inspectionPoints = inspectionPoints
        self.action = { widget, children in
            action(widget.into(), children as! Children)
        }
    }
}

extension InspectView: View {
    package var body: some View { EmptyView() }

    package func asWidget<Backend: BaseAppBackend>(
        _ children: any ViewGraphNodeChildren,
        backend: Backend
    ) -> Backend.Widget {
        let widget = child.asWidget(children, backend: backend)
        let children = children as! TupleView1<Child>.Children
        if inspectionPoints.contains(.onCreate) {
            action(children.child0.widget, children.child0.getChildren())
        }
        return widget
    }

    package func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        child.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    package func layoutableChildren<Backend: BaseAppBackend>(
        backend: Backend,
        children: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        child.layoutableChildren(backend: backend, children: children)
    }

    package func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let children = children as! TupleView1<Child>.Children
        if inspectionPoints.contains(.beforeUpdate) {
            action(children.child0.widget, children.child0.getChildren())
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

    package func commit<Backend: BaseAppBackend>(
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
        let children = children as! TupleView1<Child>.Children
        if inspectionPoints.contains(.afterUpdate) {
            action(children.child0.widget, children.child0.getChildren())
        }
    }
}

/// The `View.inspectWindow(_:)` modifier is implemented within each backend.
/// Make sure to import your chosen backend in any files where you need to
/// inspect a native window. This type simply supports the implementation of
/// those backend-specified modifiers.
package struct InspectWindowView<Child: View> {
    @Environment(\.window) var window

    var child: Child
    var action: @MainActor (_ window: Any) -> Void

    package init<WindowType>(
        child: Child,
        action: @escaping @MainActor @Sendable (WindowType) -> Void
    ) {
        self.child = child
        self.action = { window in
            action(window as! WindowType)
        }
    }
}

extension InspectWindowView: View {
    package var body: some View {
        child.onCommit {
            action(window!)
        }
    }
}
