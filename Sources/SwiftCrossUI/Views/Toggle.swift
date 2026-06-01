/// A control for toggling between two values (usually representing on and off).
public struct Toggle: View {
    @Environment(\.backend) var backend
    @Environment(\.toggleStyle) var toggleStyle

    /// The label to be shown on or beside the toggle.
    var label: String
    /// Whether the toggle is active or not.
    var active: Binding<Bool>

    /// Creates a toggle that displays a custom label.
    public init(_ label: String, active: Binding<Bool>) {
        self.label = label
        self.active = active
    }

    public var body: some View {
        switch toggleStyle.style {
            case .switch:
                HStack {
                    Text(label)

                    if backend.requiresToggleSwitchSpacer {
                        Spacer()
                    }

                    ToggleSwitch(active: active)
                }
            case .button:
                ToggleButton(label, active: active)
            case .checkbox:
                HStack {
                    Text(label)

                    Checkbox(active: active)
                }
        }
    }
}

/// A style of toggle.
public struct ToggleStyle: Sendable {
    public var style: Style

    /// A toggle switch.
    public static let `switch` = Self(style: .switch)
    /// A toggle button. Generally looks like a regular button when off and an
    /// accented button when on.
    public static let button = Self(style: .button)
    /// A checkbox.
    public static let checkbox = Self(style: .checkbox)

    public enum Style {
        case `switch`
        case button
        case checkbox
    }
}
