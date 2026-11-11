import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.CornerRadius {
    public func createCornerRadiusContainer(wrapping child: Widget) -> Widget {
        child
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.clipsToBounds = true
        widget.wantsLayer = true
        widget.layer?.cornerRadius = CGFloat(radius)
    }
}
