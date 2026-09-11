import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ViewLabelButtons {
    public func createButton(
        wrapping child: Widget
    ) -> NSView {
        let button = NSCustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setupButton()

        button.addAndSetupLabel(child)

        return button
    }

    public func updateButton(
        _ button: NSView,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSCustomButton

        button.action = action
        button.isEnabled = environment.isEnabled
        button.buttonStyle = environment.resolvedButtonStyle.kind
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding()
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle { .bordered }

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

extension ButtonStyle.Kind {
    func applyModifications(to button: NSCustomButton) {
        button.button.isHidden = true
        switch self {
            case .bordered:
                button.button.isHidden = false
                button.button.isEnabled = button.isEnabled
                button.button.isHighlighted = button.isHighlighted
            case .plain, .borderless:
                button.alphaValue = button.isEnabled
                    ? button.isHighlighted ? 0.80: 1.0
                    : 0.5
                // Why 50% disabled opacity was chosen:
                // A disabled SwiftUI .plain button looks visually the same as
                // an enabled one at 0.5 opacity.
                // Why 80% for active(pressed) was chosen:
                // A pressed SwiftUI .plain button looks visually the same as
                // a not pressed one at 0.8 opacity.
        }
    }

    var shouldRenderNativeBackground: Bool {
        switch self {
            case .bordered:
                true
            case .plain, .borderless:
                false
        }
    }

    func drawFocusRingMask(on button: NSCustomButton) {
        switch self {
            case .bordered:
                button.button.drawFocusRingMask()
            case .plain, .borderless:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
}
