import AppKit
@_spi(Backends) import SwiftCrossUI

@available(macOS 11, *)
extension AppKitBackend: BackendFeatures.Icons {
    static func sfSymbol(for icon: Icon.SystemIcon) -> NSImage? {
        let name =
            switch icon.storage {
                case .builtin(let kind):
                    switch kind {
                        case .share: "square.and.arrow.up"
                        case .plus: "plus"
                        case .back: "chevron.backward"
                        case .cut: "scissors"
                        case .copy: "document.on.document"
                        case .paste: "document.on.clipboard"
                        case .search: "magnifyingglass"
                    }
                case .custom(let name): name
            }

        return NSImage(systemSymbolName: name, accessibilityDescription: nil)
    }

    public func createIconView() -> Widget {
        NSImageView()
    }

    public func updateIconView(
        _ iconView: Widget,
        icon: Icon.SystemIcon,
        environment: EnvironmentValues
    ) {
        let iconView = iconView as! NSImageView
        let image = Self.sfSymbol(for: icon)?.withSymbolConfiguration(
            NSImage.SymbolConfiguration(
                pointSize: environment.resolvedFont.pointSize,
                weight: Self.weight(for: environment.resolvedFont.weight)
            )
        )
        iconView.image = image
        iconView.contentTintColor = environment.foregroundColor?
            .resolve(in: environment).nsColor
    }
}

extension SwiftCrossUI.Icon {
    /// Displays an SF Symbol. Only available under AppKitBackend and UIKitBackend.
    /// - Parameter sfSymbol: The SF symbol identifier for the icon to display.
    public init(sfSymbol: String) {
        self = .system(.custom(sfSymbol))
    }
}
