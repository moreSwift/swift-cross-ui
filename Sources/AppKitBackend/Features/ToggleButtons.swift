import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ToggleButtons {
    public func createToggle() -> Widget {
        let toggle = NSButton()
        toggle.setButtonType(.pushOnPushOff)
        return toggle
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! NSButton
        toggle.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        toggle.isEnabled = environment.isEnabled
        toggle.onAction = { toggle in
            let toggle = toggle as! NSButton
            onChange(toggle.state == .on)
        }
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        let toggle = toggle as! NSButton
        toggle.state = state ? .on : .off
    }
}
