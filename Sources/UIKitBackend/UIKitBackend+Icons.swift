import UIKit
import SwiftCrossUI

final class ImageView: WrapperWidget<UIImageView> {}

extension UIKitBackend: BackendFeatures.Icons {
    static func sfSymbol(for icon: Icon) -> UIImage? {
        let name =
            switch icon {
                case .share: "square.and.arrow.up"
                case .plus: "plus"
                case .back: "chevron.backward"
                case .cut: "scissors"
                case .copy: "document.on.document"
                case .paste: "document.on.clipboard"
                case .search: "magnifyingglass"
            }

        return UIImage(systemName: name)
    }

    public func createIconView() -> Widget {
        ImageView()
    }

    public func updateIconView(
        _ iconView: Widget,
        icon: Icon,
        environment: EnvironmentValues
    ) {
        let iconView = iconView as! ImageView
        let image = Self.sfSymbol(for: icon)?.applyingSymbolConfiguration(
            .init(
                pointSize: environment.resolvedFont.pointSize,
                weight: environment.resolvedFont.weight.uiSymbolWeight
            )
        )

        iconView.child.image =
            if let tintColor = environment.foregroundColor {
                image?.withTintColor(tintColor.resolve(in: environment).uiColor)
            } else {
                image
            }
    }
}

extension Font.Weight {
    var uiSymbolWeight: UIImage.SymbolWeight {
        switch self {
            case .ultraLight:
                .ultraLight
            case .thin:
                .thin
            case .light:
                .light
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            case .bold:
                .bold
            case .heavy:
                .heavy
            case .black:
                .black
        }
    }
}
