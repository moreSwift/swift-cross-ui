import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Tooltips {
    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        TooltipContainer(child)
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        let widget = widget as! TooltipContainer
        widget.setTooltip(text: tooltip)
    }
}
