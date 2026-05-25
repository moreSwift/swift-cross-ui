import CGtk3
import Gtk3
import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Icons {
    static func iconName(for icon: Icon) -> String {
        switch icon {
            case .share: "folder-publicshare-symbolic" // FIXME(kaascevich): Nonexistent on GTK3
            case .plus: "list-add-symbolic"
            case .back: "go-previous-symbolic"
            case .cut: "edit-cut-symbolic"
            case .copy: "edit-copy-symbolic"
            case .paste: "edit-paste-symbolic"
            case .search: "system-search-symbolic"
        }
    }

    public func createIconView() -> Widget {
        Gtk3.Image()
    }

    public func updateIconView(
        _ iconView: Widget,
        icon: Icon,
        environment: EnvironmentValues
    ) {
        let iconView = iconView as! Gtk3.Image
        iconView.iconName = Self.iconName(for: icon)
        iconView.pixelSize = Int(environment.resolvedFont.pointSize)
        if let tintColor = environment.foregroundColor?.resolve(in: environment) {
            iconView.css.set(property: .foregroundColor(tintColor.gtkColor))
        }
    }
}

