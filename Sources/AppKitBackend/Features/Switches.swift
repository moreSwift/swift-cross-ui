import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Switches {
    public func createSwitch() -> Widget {
        return NSSwitch()
    }

    public func updateSwitch(
        _ toggleSwitch: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.isEnabled = environment.isEnabled
        toggleSwitch.onAction = { toggleSwitch in
            let toggleSwitch = toggleSwitch as! NSSwitch
            onChange(toggleSwitch.state == .on)
        }
    }

    public func setState(ofSwitch toggleSwitch: Widget, to state: Bool) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.state = state ? .on : .off
    }
}
