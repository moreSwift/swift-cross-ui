@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.ToggleButtons {
    public func createToggle() -> Widget {
        ToggleButton()
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! ToggleButton
        toggle.label = label
        toggle.toggleHandler = onChange
        toggle.font = environment.resolvedFont
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        (toggle as! ToggleButton).state = state
    }
}
