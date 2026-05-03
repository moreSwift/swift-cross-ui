/// A type of tap gesture.
public struct TapGesture: Sendable, Hashable {
    package var kind: TapGestureKind

    /// The idiomatic "primary" interaction for the device, such as a left-click
    /// with the mouse or normal tap on a touch screen.
    public static let primary = TapGesture(kind: .primary)
    /// The idiomatic "secondary" interaction for the device, such as a
    /// right-click with the mouse or long press on a touch screen.
    public static let secondary = TapGesture(kind: .secondary)
    /// A long press of the same interaction type as ``primary``.
    ///
    /// May be equivalent to ``secondary`` on some backends, particularly on
    /// mobile devices.
    public static let longPress = TapGesture(kind: .longPress)

    package enum TapGestureKind {
        case primary, secondary, longPress
    }
}

extension View {
    /// Adds an action to perform when the user taps or clicks this view.
    ///
    /// Any tappable elements within the view will no longer be tappable with
    /// the same gesture type.
    ///
    /// - Parameters:
    ///   - gesture: The type of gesture to listen for.
    ///   - action: The action to perform.
    public func onTapGesture(
        gesture: TapGesture = .primary,
        perform action: @escaping () -> Void
    ) -> some View {
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

    func children<Backend: BaseAppBackend>(
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

    @CastBackend<BackendFeatures.TapGestures>(returnsWidget: true)
    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        backend.createTapGestureTarget(wrapping: children.child0.widget.into(), gesture: gesture)
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
    }

    @CastBackend<BackendFeatures.TapGestures>
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleView1<Content>.Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = children.child0.commit().size
        backend.setSize(of: widget, to: size.vector)
        backend.updateTapGestureTarget(
            widget,
            gesture: gesture,
            environment: environment,
            action: action
        )
    }
}
