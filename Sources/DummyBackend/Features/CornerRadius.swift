@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.CornerRadius {
    public func createCornerRadiusContainer(wrapping child: Widget) -> Widget {
        child
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.cornerRadius = radius
    }
}
