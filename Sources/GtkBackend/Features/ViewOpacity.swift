import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: Widget, to opacity: Double) {
        widget.opacity = opacity
    }
}
