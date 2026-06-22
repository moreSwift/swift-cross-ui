import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public func createFocusContainer() -> Widget {
        BaseViewWidget()
    }

    // Disabling focus on partial ViewGraph is currently not supported
    public func updateFocusContainer(
        _ widget: Widget,
        focusability: SwiftCrossUI.Focusability
    ) {}
}
