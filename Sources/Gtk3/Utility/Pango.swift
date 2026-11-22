import CGtk3

public class Pango {
    /// Shared per-widget context (GTK caches it on the widget; borrowed, do not unref).
    private let pangoContext: OpaquePointer
    /// Reusable layout: created once per Pango instance, re-set text per measurement.
    private let layout: OpaquePointer

    public init(for widget: Widget) {
        pangoContext = gtk_widget_get_pango_context(widget.widgetPointer)
        layout = pango_layout_new(pangoContext)!
        pango_layout_set_wrap(layout, PANGO_WRAP_WORD_CHAR)
    }

    deinit {
        g_object_unref(UnsafeMutableRawPointer(layout))
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
        pango_layout_set_text(layout, text, Int32(text.utf8.count))
        pango_layout_set_ellipsize(layout, ellipsize.toGtk())

        if let proposedWidth {
            pango_layout_set_width(
                layout,
                Int32((proposedWidth * Double(PANGO_SCALE)).rounded(.towardZero))
            )
        } else {
            pango_layout_set_width(layout, -1)
        }
        if let proposedHeight {
            pango_layout_set_height(
                layout,
                Int32((proposedHeight * Double(PANGO_SCALE)).rounded(.towardZero))
            )
        } else {
            pango_layout_set_height(layout, -1)
        }

        var width: Int32 = 0
        var height: Int32 = 0
        pango_layout_get_pixel_size(layout, &width, &height)

        return (
            Int(width),
            Int(height)
        )
    }
}
