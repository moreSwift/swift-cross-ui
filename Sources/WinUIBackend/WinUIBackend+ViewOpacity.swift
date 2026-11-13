@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: Widget, to opacity: Double) {
        widget.opacity = opacity
    }
}
