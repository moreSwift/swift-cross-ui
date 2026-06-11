import AppKit
import SwiftCrossUI

extension AppKitBackend {
    static func renderMenuItem(
        _ item: ResolvedMenu.Item,
        environment: EnvironmentValues
    ) -> NSMenuItem {
        switch item {
            case .button(let label, let action):
                // Custom subclass is used to keep strong reference to action
                // wrapper.
                let renderedItem = NSCustomMenuItem(
                    title: label,
                    action: nil,
                    keyEquivalent: ""
                )
                if let action, environment.isEnabled {
                    let wrappedAction = Action(action)
                    renderedItem.actionWrapper = wrappedAction
                    renderedItem.action = #selector(wrappedAction.run)
                    renderedItem.target = wrappedAction
                }
                return renderedItem
            case .toggle(let label, let value, let onChange):
                // Custom subclass is used to keep strong reference to action
                // wrapper.
                let renderedItem = NSCustomMenuItem(
                    title: label,
                    action: nil,
                    keyEquivalent: ""
                )
                renderedItem.isOn = value

                if environment.isEnabled {
                    let wrappedAction = Action {
                        onChange(!renderedItem.isOn)
                    }
                    renderedItem.actionWrapper = wrappedAction
                    renderedItem.action = #selector(wrappedAction.run)
                    renderedItem.target = wrappedAction
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
        menuItem.title = submenu.label
        menuItem.submenu = renderedMenu
        return menuItem
    }
}

final class NSCustomMenuItem: NSMenuItem {
    /// This property's only purpose is to keep a strong reference to the wrapped
    /// action so that it sticks around for long enough to be useful.
    var actionWrapper: Action?

    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
}
