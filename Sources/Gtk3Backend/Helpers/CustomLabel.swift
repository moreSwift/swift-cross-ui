import CGtk3
import Gtk3

/// A custom label subclass that supports ellipsizing multi-line text. Regular
/// `Label`s only display a single line of text when ellipsizing is enabled
/// because they don't pass their size request to their underlying Pango layout.
class CustomLabel: Label {
    override func didMoveToParent() {
        super.didMoveToParent()

        doDraw = { [weak self] _ in
            guard let self else { return }
            self.setLayoutHeight(getSizeRequest().height)
        }
    }

    private func setLayoutHeight(_ height: Int) {
        // Override the label's layout height. We do this so that the label grows
        // vertically to fill available space even though we have ellipsizing
        // enabled (which generally causes labels to limit themselves to a single line).
        //
        // This code relies on the assumption that the layout won't get recreated
        // during rendering. From reading the Gtk 3 source code I believe that's
        // unlikely, but note that the docs recommend against mutating
        // the layout returned by gtk_label_get_layout.
        let layout = gtk_label_get_layout(castedPointer())
        pango_layout_set_height(
            layout,
            Int32((Double(height) * Double(PANGO_SCALE)).rounded(.towardZero))
        )
    }
}
