import Gtk
import CGtk

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
