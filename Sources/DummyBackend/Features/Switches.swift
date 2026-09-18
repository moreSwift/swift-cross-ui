@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Switches {
    public func createSwitch() -> Widget {
        ToggleSwitch()
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        (switchWidget as! ToggleSwitch).toggleHandler = onChange
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        (switchWidget as! ToggleSwitch).state = state
    }
}
