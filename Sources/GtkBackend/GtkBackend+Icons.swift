import CGtk
import Gtk
import SwiftCrossUI

extension GtkBackend: BackendFeatures.Icons {
    static func iconName(for icon: Icon) -> String {
        // TODO(kaascevich): Use icons from libadwaita once we can link that
        // (These icons are all built in to GTK, and there aren't very many of them.)
        switch icon {
            case .share: "folder-publicshare-symbolic"
            case .plus: "list-add-symbolic"
            case .back: "go-previous-symbolic"
            case .cut: "edit-cut-symbolic"
            case .copy: "edit-copy-symbolic"
            case .paste: "edit-paste-symbolic"
            case .search: "system-search-symbolic"
        }
    }

    public func createIconView() -> Widget {
        Gtk.Image()
    }

    public func updateIconView(
        _ iconView: Widget,
        icon: Icon,
        environment: EnvironmentValues
    ) {
        let iconView = iconView as! Gtk.Image
        iconView.iconName = Self.iconName(for: icon)
        iconView.pixelSize = Int(environment.resolvedFont.pointSize)
    }
}

