import SwiftCrossUI
import Gtk
import CGtk

extension GtkBackend: BackendFeatures.ColorPickers {
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
                    red: rgba.red,
                    green: rgba.green,
                    blue: rgba.blue,
                    opacity: rgba.alpha
                )
            )
        }
    }

    public func setValue(ofColorPicker colorPicker: Widget, to color: SwiftCrossUI.Color.Resolved) {
        (colorPicker as! CustomColorButton).rgba = GdkRGBA(
            red: color.red,
            green: color.green,
            blue: color.blue,
            alpha: color.opacity
        )
    }
}

final class CustomColorButton: ColorButton {
    private var alpha: Float = 1.0

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
