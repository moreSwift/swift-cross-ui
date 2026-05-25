import AppKit
import SwiftCrossUI

extension SwiftCrossUI.Icon {
    public init(sfSymbol: String) {
        self = .custom(sfSymbol)
    }
}

@available(macOS 11, *)
extension AppKitBackend: BackendFeatures.Icons {
    static func sfSymbol(for icon: Icon) -> NSImage? {
        let name =
            switch icon.kind {
                case .share: "square.and.arrow.up"
                case .plus: "plus"
                case .back: "chevron.backward"
                case .cut: "scissors"
                case .copy: "document.on.document"
                case .paste: "document.on.clipboard"
                case .search: "magnifyingglass"
                case .custom(let name): name
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
        let image = Self.sfSymbol(for: icon)?.withSymbolConfiguration(
            .init(
                pointSize: environment.resolvedFont.pointSize,
                weight: Self.weight(for: environment.resolvedFont.weight)
            )
        )
        iconView.image = image
        iconView.contentTintColor = environment.foregroundColor?.resolve(in: environment).nsColor
    }
}
