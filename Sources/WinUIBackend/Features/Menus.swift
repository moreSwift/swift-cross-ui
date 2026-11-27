@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.AttachedMenus {
    public typealias Menu = WinUI.MenuFlyout

    public func createPopoverMenu() -> Menu {
        let flyout = MenuFlyout()
        flyout.placement = .bottomEdgeAlignedLeft
        return flyout
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.items.clear()
        for item in content.items {
            menu.items.append(renderMenuItem(item, environment: environment))
        }
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        let button = button as! WinUI.Button

        let block = createTextView() as! WinUI.TextBlock
        block.text = label
        button.content = block
        environment.apply(to: block)

        environment.apply(to: button)
        button.flyout = menu
    }

    func renderMenuItem(
        _ item: ResolvedMenu.Item,
        environment: EnvironmentValues
    ) -> MenuFlyoutItemBase {
        switch item {
            case .button(let label, let action):
                let widget = MenuFlyoutItem()
                widget.text = label
                widget.click.addHandler { _, _ in
                    action?()
                }
                widget.isEnabled = environment.isEnabled
                return widget
            case .toggle(let label, let value, let onChange):
                let widget = ToggleMenuFlyoutItem()
                widget.text = label
                widget.isChecked = value
                widget.click.addHandler { [weak widget] _, _ in
                    guard let widget else { return }
                    onChange(widget.isChecked)
                }
                widget.isEnabled = environment.isEnabled
                return widget
            case .separator:
                return MenuFlyoutSeparator()
            case .submenu(let submenu):
                let widget = MenuFlyoutSubItem()
                widget.text = submenu.label
                for subitem in submenu.content.items {
                    widget.items.append(
                        renderMenuItem(subitem, environment: environment)
                    )
                }
                return widget
            case .modifiedEnvironment(let item, let modification):
                return renderMenuItem(item, environment: modification(environment))
        }
    }
}
