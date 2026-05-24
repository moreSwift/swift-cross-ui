import AppKit
import SwiftCrossUI

@available(macOS 11, *)
extension AppKitBackend: BackendFeatures.Icons {
    static func sfSymbol(for icon: Icon) -> NSImage? {
        let name =
            switch icon {
                case .share: "square.and.arrow.up"
                case .plus: "plus"
                case .edit: "pencil"
                case .back: "chevron.backward"
            }

        return NSImage(systemSymbolName: name, accessibilityDescription: nil)
    }

    public func createIconView() -> Widget {
        NSImageView()
    }

    public func updateIconView(
        _ iconView: Widget,
        icon: Icon,
        environment: EnvironmentValues
    ) {
        let iconView = iconView as! NSImageView
        iconView.image = Self.sfSymbol(for: icon)
    }
}
