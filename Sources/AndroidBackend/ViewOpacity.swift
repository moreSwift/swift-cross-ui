import AndroidKit
@_spi(Backends) import SwiftCrossUI

extension AndroidBackend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: Widget, to opacity: Double) {
        widget.setAlpha(Float(opacity))
    }
}
