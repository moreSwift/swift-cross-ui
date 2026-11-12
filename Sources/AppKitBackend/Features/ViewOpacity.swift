import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: NSView, to opacity: Double) {
        widget.alphaValue = CGFloat(opacity)
    }
}
