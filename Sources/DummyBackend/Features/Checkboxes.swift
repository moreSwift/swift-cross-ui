@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Checkboxes {
    public func createCheckbox() -> Widget {
        Checkbox()
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        (checkboxWidget as! Checkbox).toggleHandler = onChange
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        (checkboxWidget as! Checkbox).state = state
    }
}
