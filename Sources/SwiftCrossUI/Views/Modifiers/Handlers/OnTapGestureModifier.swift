public struct TapGesture: Sendable, Hashable {
    public var kind: TapGestureKind

    /// The idiomatic "primary" interaction for the device, such as a left-click with the mouse
    /// or normal tap on a touch screen.
    public static let primary = TapGesture(kind: .primary)
    /// The idiomatic "secondary" interaction for the device, such as a right-click with the
    /// mouse or long press on a touch screen.
    public static let secondary = TapGesture(kind: .secondary)
    /// A long press of the same interaction type as ``primary``. May be equivalent to
    /// ``secondary`` on some backends, particularly on mobile devices.
    public static let longPress = TapGesture(kind: .longPress)

    public enum TapGestureKind {
        case primary, secondary, longPress
    }
}

extension View {
    /// Adds an action to perform when the user taps or clicks this view.
    ///
    /// Any tappable elements within the view will no longer be tappable with the same gesture
    /// type.
    public func onTapGesture(gesture: TapGesture = .primary, perform action: @escaping () -> Void)
        -> some View
    {
        OnTapGestureModifier(body: TupleView1(self), gesture: gesture, action: action)
    }

    /// Adds an action to run when this view is clicked. Any clickable elements
    /// within the view will no longer be clickable.
    @available(*, deprecated, renamed: "onTapGesture(gesture:perform:)")
    public func onClick(perform action: @escaping () -> Void) -> some View {
        onTapGesture(perform: action)
    }
}

struct OnTapGestureModifier<Content: View>: TypeSafeView {
    typealias Children = TupleView1<Content>.Children

    var body: TupleView1<Content>
    var gesture: TapGesture
    var action: () -> Void

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    func asWidget<Backend: AppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        backend.createTapGestureTarget(wrapping: children.child0.widget.into(), gesture: gesture)
    }

    func update<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        backend: Backend,
        dryRun: Bool
    ) -> ViewUpdateResult {
        let childResult = children.child0.update(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment,
            dryRun: dryRun
        )
        if !dryRun {
            backend.setSize(of: widget, to: childResult.size.size)
            backend.updateTapGestureTarget(
                widget,
                gesture: gesture,
                environment: environment,
                action: action
            )
        }
        return childResult
    }
}
