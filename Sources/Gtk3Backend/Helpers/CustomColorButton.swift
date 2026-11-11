import SwiftCrossUI
import Gtk3
import CGtk3

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
