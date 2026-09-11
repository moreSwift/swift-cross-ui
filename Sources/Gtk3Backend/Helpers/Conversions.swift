import Gtk3
@_spi(Backends) import SwiftCrossUI

extension SwiftCrossUI.Color.Resolved {
    public var gtkColor: Gtk3.Color {
        Gtk3.Color(Double(red), Double(green), Double(blue), Double(opacity))
    }
}
