@_spi(Backends) import SwiftCrossUI
import WinUI
import UWP

extension WinUIBackend: BackendFeatures.StringLabelButtons {
    public func createSimpleButton() -> Widget {
        let button = WinUI.Button()
        button.click.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            internalState.buttonClickActions[ObjectIdentifier(button)]?()
        }
        return button
    }

    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! WinUI.Button

        let block = createTextView() as! WinUI.TextBlock
        block.text = label
        button.content = block
        environment.apply(to: block)

        environment.apply(to: button)
        internalState.buttonClickActions[ObjectIdentifier(button)] = action
    }
}

extension WinUIBackend: BackendFeatures.ViewLabelButtons {
    public func createButton(
        wrapping widget: Widget
    ) -> Widget {
        let button = CustomButton()
        button.content = widget
        return button
    }

    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! CustomButton
        button.action = action
        button.buttonStyle = environment.resolvedButtonStyle.kind
        button.enabled = environment.isEnabled
        switch environment.colorScheme {
            case .light:
                button.requestedTheme = .light
            case .dark:
                button.requestedTheme = .dark
        }
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding()
            case .plain, .borderless: SIMD2(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle { .bordered }

    func measureBorderedButtonPadding() -> SIMD2<Int> {
        if let borderedButtonPadding {
            return borderedButtonPadding
        }

        let dummyButton = Button()
        let placeholder = Canvas()
        let placeholderSize = SIMD2<Double>(40, 40)
        placeholder.width = placeholderSize.x
        placeholder.height = placeholderSize.y
        dummyButton.content = placeholder

        let buttonSize = Self.naturalSize(of: dummyButton)

        let result = SIMD2(
            buttonSize.x - Int(placeholderSize.x),
            buttonSize.y - Int(placeholderSize.y)
        )

        borderedButtonPadding = result
        return result
    }
}
