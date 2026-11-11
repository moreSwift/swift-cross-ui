import CGtk

/// A type erased container for objects conforming to `Gtk.Root`.
///
/// https://docs.gtk.org/gtk4/iface.Root.html
open class AnyRoot: GObject {
    /// Set focus to a specific widget or nil.
    /// This is the Gtk equivalent of AppKit's `NSWindow.makeFirstResponder(_:)`.
    public func setFocus(to widget: Widget?) {
        gtk_root_set_focus(self.opaquePointer, widget?.widgetPointer)
    }
}
