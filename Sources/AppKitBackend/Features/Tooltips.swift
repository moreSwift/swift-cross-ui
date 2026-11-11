import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Tooltips {
    public func createTooltipContainer(wrapping child: NSView) -> NSView {
        child
    }

    public func updateTooltipContainer(_ widget: NSView, tooltip: String) {
        widget.toolTip = tooltip
    }
}
