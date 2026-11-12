@_spi(Backends) import SwiftCrossUI
import UIKit

extension UIKitBackend: BackendFeatures.ViewOpacity {
    public func setOpacity(of widget: any WidgetProtocol, to opacity: Double) {
        widget.view.alpha = CGFloat(opacity)
    }
}
