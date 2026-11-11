import Gtk
@_spi(Backends) import SwiftCrossUI

extension SwiftCrossUI.Color.Resolved {
    public var gtkColor: Gtk.Color {
        Gtk.Color(red, green, blue, opacity)
    }
}
