import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ColorPickers {
    public func createColorPicker() -> Widget {
        CustomColorButton()
    }

    public func updateColorPicker(
        _ colorPicker: Widget,
        supportsOpacity: Bool,
        environment: EnvironmentValues,
        onChange: @escaping (SwiftCrossUI.Color.Resolved) -> Void
    ) {
        let colorButton = colorPicker as! CustomColorButton
        colorButton.sensitive = environment.isEnabled
        colorButton.useAlpha = supportsOpacity
        colorButton.colorSet = { colorButton in
            let rgba = (colorButton as! CustomColorButton).rgba
            onChange(
                Color.Resolved(
                    red: Float(rgba.red),
                    green: Float(rgba.green),
                    blue: Float(rgba.blue),
                    opacity: Float(rgba.alpha)
                )
            )
        }
    }

    public func setValue(ofColorPicker colorPicker: Widget, to color: SwiftCrossUI.Color.Resolved) {
        (colorPicker as! CustomColorButton).rgba = GdkRGBA(
            red: gdouble(color.red),
            green: gdouble(color.green),
            blue: gdouble(color.blue),
            alpha: gdouble(color.opacity)
        )
    }
}
