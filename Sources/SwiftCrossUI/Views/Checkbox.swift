/// A checkbox control that is either on or off.
struct Checkbox: ElementaryView, View {
    /// Whether the checkbox is active or not.
    private var active: Binding<Bool>

    /// Creates a checkbox.
    public init(isOn active: Binding<Bool>) {
        self.active = active
    }

    public func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createCheckbox()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        return ViewLayoutResult.leafView(
            size: ViewSize(backend.naturalSize(of: widget))
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateCheckbox(widget, environment: environment) { newActiveState in
            if active.wrappedValue != newActiveState {
                active.wrappedValue = newActiveState
            }
        }
        backend.setState(ofCheckbox: widget, to: active.wrappedValue)
    }
}
