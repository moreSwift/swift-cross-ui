@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.StringLabelButtons {
    public func createSimpleButton() -> Widget {
        SimpleButton()
    }

    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! SimpleButton
        button.label = label
        button.action = action
        button.font = environment.resolvedFont
    }
}
