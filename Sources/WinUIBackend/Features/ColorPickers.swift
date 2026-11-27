import SwiftCrossUI
import WindowsFoundation
import WinUI
import UWP

extension WinUIBackend: BackendFeatures.ColorPickers {
    public func createColorPicker() -> Widget {
        let colorSwatch = createColorableRectangle()
        colorSwatch.horizontalAlignment = HorizontalAlignment.center
        colorSwatch.verticalAlignment = VerticalAlignment.center

        let button = ColorButton()
        button.content = colorSwatch

        button.buttonSizeChangedEventCleanup = button.sizeChanged
            .addHandler { [weak colorSwatch, weak button] _, args in
                guard let args, let padding = button?.padding else { return }

                colorSwatch?.width = Double(args.newSize.width) - padding.left - padding.right
                colorSwatch?.height = Double(args.newSize.height) - padding.top - padding.bottom
            }
        return button
    }

    public func updateColorPicker(
        _ colorPicker: Widget,
        supportsOpacity: Bool,
        environment: EnvironmentValues,
        onChange: @escaping (SwiftCrossUI.Color.Resolved) -> Void
    ) {
        let colorButton = colorPicker as! ColorButton
        colorButton.supportsOpacity = supportsOpacity
        colorButton.isEnabled = environment.isEnabled
        colorButton.onChange = { onChange(SwiftCrossUI.Color.Resolved(uwpColor: $0)) }
    }

    public func setValue(ofColorPicker colorPicker: Widget, to color: SwiftCrossUI.Color.Resolved) {
        (colorPicker as! ColorButton).setColor(to: color.uwpColor)
    }
}
