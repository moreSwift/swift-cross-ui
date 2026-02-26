/// A light switch style control that is either on or off.
struct ToggleSwitch: ElementaryView, View {
    /// Whether the switch is active or not.
    private var active: Binding<Bool>

    /// Creates a switch.
    public init(isOn active: Binding<Bool>) {
        self.active = active
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createSwitch()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let size = ViewSize(backend.naturalSize(of: widget))
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateSwitch(widget, environment: environment) { newActiveState in
            if active.wrappedValue != newActiveState {
                active.wrappedValue = newActiveState
            }
        }
        backend.setState(ofSwitch: widget, to: active.wrappedValue)
    }
}
