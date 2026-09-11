import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.PopoverMenus {
    public typealias Menu = Gtk3.Menu

    public func createPopoverMenu() -> Menu {
        Gtk3.Menu()
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        // Update menu model and action handlers
        let actionGroup = Gtk3.GSimpleActionGroup()
        let model = renderMenu(
            content,
            actionMap: actionGroup,
            actionNamespace: "menu",
            actionPrefix: nil,
            environment: environment
        )
        menu.bindModel(model)
        menu.insertActionGroup("menu", actionGroup)

        // menu.cssProvider.loadCss(
        //     from: """
        //         menu {
        //             background: rgba(45, 45, 45, 1);
        //             color: white;
        //         }
        //         menuitem:hover {
        //             background: magenta;
        //             color: white;
        //         }
        //         """)
    }

    public func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        menu.popUpAtWidget(widget, relativePosition: position)
        menu.onHide = {
            handleClose()
        }
    }
}
