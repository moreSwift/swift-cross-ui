import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.CornerRadius {
    // TODO(bbrk24): Create a custom clipping container. Setting the CSS corner radius doesn't work
    //   if the widget is already a container widget.
    public func createCornerRadiusContainer(wrapping child: Widget) -> Widget {
        child
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.css.set(property: .cornerRadius(radius))
    }
}
