import CGtk

/// Swift representation of a Gtk CSS provider
public class CSSProvider {
    var pointer: UnsafeMutablePointer<GtkCssProvider>
    var display: OpaquePointer
    /// The CSS last loaded. A provider is display-wide, so a load restyles every widget on the
    /// display: a load of the same text again is skipped.
    private var loaded: String?

    public init(
        forDisplay display: OpaquePointer = gdk_display_get_default(),
        priority: UInt32 = UInt32(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
    ) {
        pointer = gtk_css_provider_new()
        self.display = display
        gtk_style_context_add_provider_for_display(display, OpaquePointer(pointer), priority)
    }

    deinit {
        gtk_style_context_remove_provider_for_display(display, OpaquePointer(pointer))
    }

    /// Loads data into css_provider.
    ///
    /// This clears any previously loaded information.
    ///
    /// Deprecated since: 4.12
    public func loadCss(from data: String) {
        guard data != loaded else { return }
        loaded = data
        // TODO: Connect to parsing-error signal to log parsing errors.
        // The length is in UTF-8 bytes: `count` (characters) cut CSS holding a non-ASCII font name short.
        gtk_css_provider_load_from_data(pointer, data, gssize(data.utf8.count))
    }
}
