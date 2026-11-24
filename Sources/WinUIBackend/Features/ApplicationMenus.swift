@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ApplicationMenus {
    public func setApplicationMenu(
        _ submenus: [ResolvedMenu.Submenu],
        environment: EnvironmentValues
    ) {
        let items = submenus.map { submenu in
            let item = MenuBarItem()
            item.title = submenu.label
            for subitem in submenu.content.items {
                item.items.append(
                    renderMenuItem(subitem, environment: environment)
                )
            }
            return item
        }

        for window in windows {
            window.menuBar.items.clear()
            for item in items {
                window.menuBar.items.append(item)
            }
            window.setMenuBarVisible(!items.isEmpty)
            window.menuBar.requestedTheme = .dark
        }
    }
}
