import CGtk

open class AnyRoot: GObject {
    /// Set focus to a specific widget or nil.
    /// Equivalent to `NSWindow.makeFirstResponder(_:)`
    public func setFocus(to widget: Widget?) {
        gtk_root_set_focus(self.opaquePointer, widget?.widgetPointer)
    }
}
