import SwiftCrossUI
import Gtk3
import CGtk3

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
        colorButton.colorSet = {
            let rgba = ($0 as! CustomColorButton).rgba
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

final class CustomColorButton: ColorButton {
    var useAlpha: Bool {
        get {
            gtk_color_chooser_get_use_alpha(opaquePointer) != 0
        }
        set {
            gtk_color_chooser_set_use_alpha(opaquePointer, newValue ? 1 : 0)
        }
    }

    private var alpha: gdouble = 1.0

    var rgba: GdkRGBA {
        get {
            var result = GdkRGBA()
            gtk_color_chooser_get_rgba(opaquePointer, &result)
            if !useAlpha {
                result.alpha = alpha
            }
            return result
        }
        set {
            alpha = newValue.alpha
            // The method takes a pointer, but internally copies the value anyways, so we have no
            // obligation to keep the pointer valid.
            withUnsafePointer(to: newValue) { rgbaPtr in
                gtk_color_chooser_set_rgba(opaquePointer, rgbaPtr)
            }
        }
    }
}
