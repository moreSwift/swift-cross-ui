import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ViewLabelButtons {
    public func createButton(
        wrapping child: Widget
    ) -> NSView {
        let button = NSCustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addAndSetupLabel(child)

        return button
    }

    public func updateButton(
        _ button: NSView,
        environment: EnvironmentValues,
        pressStateChanged: @escaping (Bool) -> Void,
        action: @escaping () -> Void
    ) {
        let button = button as! NSCustomButton

        button.onPressStateChange = pressStateChanged
        button.action = action
        button.isEnabled = environment.isEnabled
        button.buttonStyle = environment.resolvedButtonStyle.baseButtonStyle.kind
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.baseButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding()
            case .plain: SIMD2<Int>(0, 0)
        }
    }

    func measureBorderedButtonPadding() -> SIMD2<Int> {
        if let borderedButtonPadding { return borderedButtonPadding }

        let testString = "E"
        let dummyButton = NSButton()
        dummyButton.title = testString
        dummyButton.controlSize = .regular
        dummyButton.sizeToFit()

        let field = NSTextField(wrappingLabelWithString: "")
        field.stringValue = testString
        field.font = dummyButton.font
        let textSize = field.intrinsicContentSize

        let buttonSize = dummyButton.intrinsicContentSize

        let result = SIMD2(
            Int(buttonSize.width - textSize.width),
            Int(buttonSize.height - textSize.height)
        )

        borderedButtonPadding = result
        return result
    }
}

extension BaseButtonStyle.Kind {
    func applyModifications(to button: NSCustomButton) {
        switch self {
            case .bordered:
                button.setupButton()
                button.button?.isEnabled = button.isEnabled
                button.button?.isHighlighted = button.isHighlighted
            case .plain:
                button.removeButton()
        }
    }

    var shouldRenderNativeBackground: Bool {
        switch self {
            case .bordered:
                true
            case .plain:
                false
        }
    }

    func drawFocusRingMask(on button: NSCustomButton) {
        switch self {
            case .bordered:
                button.button?.drawFocusRingMask()
            case .plain:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
}
