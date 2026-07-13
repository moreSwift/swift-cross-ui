import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension SwiftCrossUI.Icon {
    public init(gtkIcon: String) {
        self = .system(.custom(gtkIcon))
    }
}

extension GtkBackend: BackendFeatures.Icons {
    static func iconName(for icon: Icon.SystemIcon) -> String {
        // TODO(kaascevich): Use icons from libadwaita once we can link that
        // (These icons are all built in to GTK, and there aren't very many of them.)
        switch icon.storage {
            case .builtin(let kind):
                switch kind {
                    case .share: "folder-publicshare-symbolic"
                    case .plus: "list-add-symbolic"
                    case .back: "go-previous-symbolic"
                    case .cut: "edit-cut-symbolic"
                    case .copy: "edit-copy-symbolic"
                    case .paste: "edit-paste-symbolic"
                    case .search: "system-search-symbolic"
                }
            case .custom(let name): name
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
        switch icon.kind {
            case .system(let icon):
                let iconView = iconView as! Gtk.Image
                iconView.iconName = Self.iconName(for: icon)
                iconView.pixelSize = Int(environment.resolvedFont.pointSize)
                if let tintColor = environment.foregroundColor?.resolve(in: environment) {
                    iconView.css.set(property: .foregroundColor(tintColor.gtkColor))
                }
        }
    }
}

