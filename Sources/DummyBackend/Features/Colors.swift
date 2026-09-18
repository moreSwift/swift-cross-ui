@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Colors {
    public func createColorableRectangle() -> Widget {
        Rectangle()
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        (widget as! Rectangle).color = color
    }
}
