@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.Tooltips {
    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        // TODO(bbrk24): Look into removing the container, like on AppKit
        TooltipContainer(child: child)
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        let widget = widget as! TooltipContainer
        widget.tooltip.content = tooltip
    }
}
