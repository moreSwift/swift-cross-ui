import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.FocusDisabling {
    public func createFocusContainer() -> NSView {
        let container = FocusabilityContainer()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    public func updateFocusContainer(
        _ widget: NSView,
        focusability: Focusability
    ) {
        let container = widget as! FocusabilityContainer
        container.focusability = focusability
    }
}
