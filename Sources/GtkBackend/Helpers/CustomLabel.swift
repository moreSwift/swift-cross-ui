import CGtk
import Gtk

/// A custom label subclass that supports ellipsizing multi-line text. Regular
/// `Label`s only display a single line of text when ellipsizing is enabled
/// because they don't pass their size request to their underlying Pango layout.
class CustomLabel: Label {
    override func setSizeRequest(width: Int, height: Int) {
        super.setSizeRequest(width: width, height: height)

        // Override the label's layout height. We do this so that the label grows
        // vertically to fill available space even though we have ellipsizing
        // enabled (which generally causes labels to limit themselves to a single line).
        //
        // This code relies on the assumption that the layout won't get recreated
        // until after the label gets rendered. The docs recommend against mutating
        // the layout returned by gtk_label_get_layout.
        //
        // Ideally we'd use an Inscription instead, because it has this behavior
        // by default, but that's only available from Gtk 4.8, and the predecessor
        // CellRendererText isn't a widget.
        let layout = gtk_label_get_layout(opaquePointer)
        pango_layout_set_height(
            layout,
            Int32(
                (Double(height) * Double(PANGO_SCALE))
                    .rounded(.towardZero)
            )
        )
    }
}
