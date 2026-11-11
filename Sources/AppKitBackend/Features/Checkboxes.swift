import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Checkboxes {
    public func createCheckbox() -> Widget {
        NSButton(checkboxWithTitle: "", target: nil, action: nil)
    }

    public func updateCheckbox(
        _ checkbox: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let checkbox = checkbox as! NSButton
        checkbox.isEnabled = environment.isEnabled
        checkbox.onAction = { toggle in
            let checkbox = toggle as! NSButton
            onChange(checkbox.state == .on)
        }
    }

    public func setState(ofCheckbox checkbox: Widget, to state: Bool) {
        let toggle = checkbox as! NSButton
        toggle.state = state ? .on : .off
    }
}
