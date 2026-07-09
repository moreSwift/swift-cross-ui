/// A control that initiates an action.
public struct Button<Label: View> {
    public typealias Content = TupleView1<Label>
    /// The label to show on the button.
    @_spi(Backends) public var label: () -> Label
    /// The action to be performed when the button is clicked.
    @_spi(Backends) public var action: @MainActor @Sendable () -> Void

    /// Creates a button that displays a text label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    public init(
        _ label: String,
        action: @escaping @MainActor @Sendable () -> Void = {}
    ) where Label == TupleView1<Text> {
        self.label = { TupleView1(Text(label)) }
        self.action = action
    }

    /// Creates a button that displays a custom view as label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    @MainActor
    public init (
        action: @escaping @MainActor @Sendable () -> Void = {},
        @ViewBuilder label: @escaping @MainActor @Sendable () -> Label
    ) {
        self.label = label
        self.action = action
    }

    private struct ConstrainedButtonLabel<ConstrainedLabel: View>: View {
        @Environment(\.buttonPadding.x) var horizontalPadding

        var content: ConstrainedLabel
        var width: Int?

        var body: some View {
            content.ifLet(width) { view, width in
                view.frame(width: Double(width - horizontalPadding))
            }
        }
    }

    @MainActor
    @available(
        *,
        deprecated,
        message: "Use @ViewBuilder init of Button instead and apply a frame modifier to the label."
    )
    public func _buttonWidth(_ width: Int?) -> Button<some View> {
        return Button<TupleView1<ConstrainedButtonLabel<TupleView1<Label>>>>(
            action: action,
            label: { ConstrainedButtonLabel(content: body, width: width) }
        )
    }
}

@MainActor
extension Button: TypeSafeView {
    public var body: TupleView1<Label> {
        label()
    }

    typealias Children = TupleViewChildren1<Label>

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        Children(label(), backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        backend.createButton(wrapping: children.child0.widget.into())
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let buttonPadding = backend.buttonPadding(in: environment)
        let childEnvironment = backend.computeButtonLabelEnvironment(from: environment)

        var childProposal = proposedSize
        if let proposedWidth = proposedSize.width {
            childProposal.width = max(proposedWidth - Double(buttonPadding.x), 0)
        }
        if let proposedHeight = proposedSize.height {
            childProposal.height = max(proposedHeight - Double(buttonPadding.y), 0)
        }

        let childResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: childProposal,
            environment: childEnvironment
        )

        backend.updateButton(
            widget,
            environment: environment,
            action: action
        )

        // Buttons should always be set to label size + padding.
        // The backend representation of a button is expected not to have a minSize.
        let size = SIMD2(
            Int(childResult.size.width) + buttonPadding.x,
            Int(childResult.size.height) + buttonPadding.y
        )

        return ViewLayoutResult.leafView(size: ViewSize(size))
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        _ = children.child0.commit()
        backend.setSize(of: widget, to: layout.size.vector)
    }
}

@MainActor
extension Button where Label == TupleView1<Text> {
    public var _asMenuItems: [MenuItem] {
        [.button(self)]
    }
}
