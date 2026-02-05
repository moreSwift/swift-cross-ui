import CGtk3

public class Pango {
    private var pangoContext: OpaquePointer

    /// Create a default pango instance with default context.
    /// Create a pango context for a specific
    public init(for widget: Widget) {
        pangoContext = gtk_widget_create_pango_context(widget.widgetPointer)
    }

    deinit {
        g_object_unref(UnsafeMutableRawPointer(pangoContext))
    }

    /// Gets the size of the given text in pixels using the default font. If supplied, `proposedWidth`
    /// acts as a suggested width. The text will attempt to take up less than or equal to the proposed
    /// width but if the text wrapping strategy doesn't allow the text to become as small as required
    /// than it may take up more the proposed width.
    ///
    /// Uses the `PANGO_WRAP_WORD_CHAR` text wrapping mode.
    public func getTextSize(
        _ text: String,
        ellipsize: EllipsizeMode,
        proposedWidth: Double? = nil,
        proposedHeight: Double? = nil
    ) -> (width: Int, height: Int) {
        let layout = pango_layout_new(pangoContext)!
        pango_layout_set_text(layout, text, Int32(text.utf8.count))
        pango_layout_set_wrap(layout, PANGO_WRAP_WORD_CHAR)
        pango_layout_set_ellipsize(layout, ellipsize.toGtk())

        if let proposedWidth {
            pango_layout_set_width(
                layout,
                Int32((proposedWidth * Double(PANGO_SCALE)).rounded(.towardZero))
            )
        }
        if let proposedHeight {
            pango_layout_set_height(
                layout,
                Int32((proposedHeight * Double(PANGO_SCALE)).rounded(.towardZero))
            )
        }

        var width: Int32 = 0
        var height: Int32 = 0
        pango_layout_get_pixel_size(layout, &width, &height)

        g_object_unref(UnsafeMutableRawPointer(layout))

        return (
            Int(width),
            Int(height)
        )
    }
}
