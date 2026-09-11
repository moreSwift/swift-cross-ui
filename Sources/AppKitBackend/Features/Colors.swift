import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Colors {
    // NB: We deliberately use the default implementation of `resolveAdaptiveColor(_:in:)`,
    // since that uses the adaptive colors from AppKit/UIKit.

    public func createColorableRectangle() -> Widget {
        let widget = NSView()
        widget.wantsLayer = true
        return widget
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        widget.layer?.backgroundColor = color.nsColor.cgColor
    }
}
