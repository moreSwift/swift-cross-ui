import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: Widget, to opacity: Double) {
        widget.opacity = opacity
    }
}
