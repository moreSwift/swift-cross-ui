@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.ViewLabelButtons {
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = Button()
        button.label = widget

        return button
    }

    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! Button
        button.buttonStyle = environment.resolvedButtonStyle
        button.action = action
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        SIMD2<Int>(0, 0)
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}
