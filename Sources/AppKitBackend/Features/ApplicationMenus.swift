import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ApplicationMenus {
    public func setApplicationMenu(
        _ submenus: [ResolvedMenu.Submenu],
        environment: EnvironmentValues
    ) {
        MenuBar.setUpMenuBar(extraMenus: submenus.map {
            Self.renderSubmenu($0, environment: environment)
        })
    }

    static func renderMenuItem(
        _ item: ResolvedMenu.Item,
        environment: EnvironmentValues
    ) -> NSMenuItem {
        switch item {
            case .button(let label, let action):
                // Custom subclass is used to keep strong reference to action
                // wrapper.
                let renderedItem = NSCustomMenuItem()
                renderedItem.attributedTitle = attributedString(
                    for: label,
                    in: environment,
                    useTextColor: true
                )

                if let action, environment.isEnabled {
                    renderedItem.actionCallback = action
                    renderedItem.action = #selector(renderedItem.runAction)
                    renderedItem.target = renderedItem
                }
                return renderedItem
            case .toggle(let label, let value, let onChange):
                // Custom subclass is used to keep strong reference to action
                // wrapper.
                let renderedItem = NSCustomMenuItem()
                renderedItem.attributedTitle = attributedString(
                    for: label,
                    in: environment,
                    useTextColor: true
                )
                renderedItem.isOn = value

                if environment.isEnabled {
                    renderedItem.actionCallback = { [unowned renderedItem] in
                        onChange(!renderedItem.isOn)
                    }
                    renderedItem.action = #selector(renderedItem.runAction)
                    renderedItem.target = renderedItem
                }

                return renderedItem
            case .separator:
                return NSCustomMenuItem.separator()
            case .submenu(let submenu):
                return renderSubmenu(submenu, environment: environment)
            case .modifiedEnvironment(let item, let modification):
                return renderMenuItem(
                    item,
                    environment: modification(environment)
                )
        }
    }

    static func renderSubmenu(
        _ submenu: ResolvedMenu.Submenu,
        environment: EnvironmentValues
    ) -> NSMenuItem {
        let renderedMenu = NSMenu()
        renderedMenu.items = submenu.content.items.map {
            Self.renderMenuItem($0, environment: environment)
        }

        let menuItem = NSMenuItem()
        menuItem.attributedTitle = attributedString(
            for: submenu.label,
            in: environment,
            useTextColor: true
        )
        menuItem.submenu = renderedMenu
        return menuItem
    }
}
