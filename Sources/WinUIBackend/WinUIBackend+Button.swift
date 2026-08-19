import SwiftCrossUI
import WinUI
import UWP

extension WinUIBackend {
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
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding()
            case .plain, .borderless: SIMD2(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle { .bordered }

    func measureBorderedButtonPadding() -> SIMD2<Int> {
        if let borderedButtonPadding { return borderedButtonPadding }

        let testString = "E"
        let dummyButton = Button()
        let block = TextBlock()
        block.text = testString
        dummyButton.content = block

        let buttonSize = Self.naturalSize(of: dummyButton)
        let textSize = Self.naturalSize(of: block)

        let result = SIMD2(
            Int(buttonSize.x - textSize.x),
            Int(buttonSize.y - textSize.y)
        )

        borderedButtonPadding = result
        return result
    }
}

fileprivate final class CustomButton: WinUI.Button {
    fileprivate var action: (() -> Void)?

    private var isPointerCaptured = false
    fileprivate var isHighlighted = false {
        didSet {
            buttonStyle.applyModifications(self)
        }
    }

    fileprivate var buttonStyle: ButtonStyle.Kind = .bordered {
        didSet {
            if buttonStyle != oldValue {
                updateButtonAppearance()
            }
        }
    }

    // Sadly we can't override isEnabled due to it not being an open property
    public var enabled: Bool = true {
        didSet {
            self.isEnabled = enabled

            if !enabled {
                isPointerCaptured = false
                isHighlighted = false
            }

            buttonStyle.applyModifications(self)
        }
    }

    override init() {
        super.init()
        padding = Thickness.null
        horizontalContentAlignment = HorizontalAlignment.center
        verticalContentAlignment = VerticalAlignment.center

        click.addHandler { [weak self] _, _ in
            guard let self else { return }
            self.action?()
        }
    }

    override func onPointerPressed(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerPressed(e)
        isPointerCaptured = true
        isHighlighted = true
    }

    override func onPointerMoved(_ e: PointerRoutedEventArgs!) throws {
        try super.onPointerMoved(e)

        if isPointerCaptured {
            // Pointer position relative to the button.
            guard let currentPoint = try e.getCurrentPoint(self) else { return }
            let position = currentPoint.position

            let width = self.actualWidth
            let height = self.actualHeight

            // Apparently windows uses 0 <= x < actualWidth ¯\_(ツ)_/¯
            if
                (0..<width).contains(Double(position.x)),
                (0..<height).contains(Double(position.y))
            {
                isHighlighted = true
            } else {
                isHighlighted = false
            }
        }
    }

    override func onPointerReleased(_ event: PointerRoutedEventArgs!) throws {
        try super.onPointerReleased(event)
        isPointerCaptured = false
        isHighlighted = false
    }

    override func onPointerCaptureLost(_ event: PointerRoutedEventArgs!) throws {
        try super.onPointerCaptureLost(event)
        isPointerCaptured = false
        isHighlighted = false
    }

    override func onKeyDown(_ event: KeyRoutedEventArgs!) throws {
        try super.onKeyDown(event)

        let targetKey = event.key

        if [.space, .enter].contains(targetKey) {
            isHighlighted = true
        }
    }

    override func onKeyUp(_ event: KeyRoutedEventArgs!) throws {
        try super.onKeyUp(event)

        let targetKey = event.key

        if [.space, .enter].contains(targetKey) {
            isHighlighted = false
        }
    }

    override func onLostFocus(_ event: RoutedEventArgs!) throws {
        try super.onLostFocus(event)
        isPointerCaptured = false
        isHighlighted = false
    }

    private func updateButtonAppearance() {
        buttonStyle.applyModifications(self)
        buttonStyle.updateRenderedStyle(self)
    }
}

extension ButtonStyle.Kind {
    fileprivate func updateRenderedStyle(_ button: CustomButton) {
        guard let resources = button.resources else { return }

        switch self {
            case .bordered:
                _ = try? button.clearValue(WinUI.Button.backgroundProperty)
                _ = try? button.clearValue(WinUI.Button.borderBrushProperty)
                _ = try? button.clearValue(WinUI.Button.borderThicknessProperty)
                _ = try? button.clearValue(WinUI.Button.cornerRadiusProperty)

                _ = resources.remove("ButtonBackgroundPointerOver")
                _ = resources.remove("ButtonBackgroundPressed")
                _ = resources.remove("ButtonBackgroundDisabled")

                _ = resources.remove("ButtonBorderBrushPointerOver")
                _ = resources.remove("ButtonBorderBrushPressed")
                _ = resources.remove("ButtonBorderBrushDisabled")
            case .plain, .borderless:
                let transparentBrush = SolidColorBrush(UWP.Color.transparent)
                button.background = transparentBrush
                button.borderBrush = transparentBrush
                button.borderThickness = Thickness.null
                button.cornerRadius = CornerRadius.null

                _ = resources.insert("ButtonBackgroundPointerOver", transparentBrush)
                _ = resources.insert("ButtonBackgroundPressed", transparentBrush)
                _ = resources.insert("ButtonBackgroundDisabled", transparentBrush)

                _ = resources.insert("ButtonBorderBrushPointerOver", transparentBrush)
                _ = resources.insert("ButtonBorderBrushPressed", transparentBrush)
                _ = resources.insert("ButtonBorderBrushDisabled", transparentBrush)
        }
    }

    fileprivate func applyModifications(_ button: CustomButton) {
        switch self {
            case .bordered: button.opacity = 1.0
            case .plain, .borderless:
                button.opacity = button.enabled
                    ? button.isHighlighted ? 0.7: 1.0
                    : 0.365
                // Why 36.5% opacity was chosen
                // https://github.com/microsoft/microsoft-ui-xaml/blob/fc2f821173298e8130fb5b143373ba70793bc251/src/controls/dev/CommonStyles/Common_themeresources_any.xaml#L8
                // 5D = 93 in base 10, 93 / 255 = 0.3647 ~ 0.365
        }
    }
}

extension UWP.Color {
    static let transparent: Self = Color(a: 0, r: 0, g: 0, b: 0)
}

extension WinUI.Thickness {
    static let null: Self = Thickness(left: 0, top: 0, right: 0, bottom: 0)
}

extension WinUI.CornerRadius {
    static let null: Self = CornerRadius(topLeft: 0, topRight: 0, bottomRight: 0, bottomLeft: 0)
}
