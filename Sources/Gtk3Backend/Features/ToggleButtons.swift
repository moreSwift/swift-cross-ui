import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ToggleButtons {
    public func createToggle() -> Widget {
        return ToggleButton()
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! Gtk3.ToggleButton
        toggle.label = label
        toggle.sensitive = environment.isEnabled
        toggle.toggled = { widget in
            onChange(widget.active)
        }
        toggle.css.clear()
        // This is a control, but we set isControl to false anyway because isControl overrides
        // the button background and makes the on and off states of the toggle look identical.
        toggle.css.set(properties: Self.cssProperties(for: environment, isControl: false))
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        (toggle as! Gtk3.ToggleButton).active = state
    }
}
