import Foundation

// TODO: Factor out `menuImplementationStyle` and rely on conformances instead

public typealias AppBackend_Menus =
    AppBackend_ButtonMenu & AppBackend_PopoverMenu

@MainActor
public protocol AppBackend_MenuBase<Menu>: AppBackend_Widgets {
    /// The underlying menu type. Can be a wrapper or subclass.
    associatedtype Menu

    /// How the backend handles rendering of menu buttons.
    ///
    /// This affects which menu-related methods are called.
    var menuImplementationStyle: MenuImplementationStyle { get }

    /// Creates a popover menu (the sort you often see when right clicking on
    /// apps).
    ///
    /// The menu won't be visible when first created.
    ///
    /// - Returns: A popover menu.
    func createPopoverMenu() -> Menu

    /// Updates a popover menu's content and appearance.
    ///
    /// - Parameters:
    ///   - menu: The menu to update.
    ///   - content: The menu content.
    ///   - environment: The current environment.
    func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    )
}

@MainActor
public protocol AppBackend_ButtonMenu: AppBackend_MenuBase {
    /// Sets a button's label and menu.
    ///
    /// Only used when ``AppBackend_MenuBase/menuImplementationStyle`` is
    /// ``MenuImplementationStyle/menuButton``.
    ///
    /// - Parameters:
    ///   - button: The button to update.
    ///   - label: The button's label.
    ///   - menu: The menu to show when the button is clicked/tapped.
    ///   - environment: The current environment.
    func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    )
}

@MainActor
public protocol AppBackend_PopoverMenu: AppBackend_MenuBase {
    /// Shows the popover menu at a position relative to the given widget.
    ///
    /// Only used when ``AppBackend_MenuBase/menuImplementationStyle`` is
    /// ``MenuImplementationStyle/dynamicPopover``.
    ///
    /// - Parameters:
    ///   - menu: The menu to show.
    ///   - position: The position to show the menu at, relative to `widget`.
    ///   - widget: The widget to attach `menu` to.
    ///   - handleClose: The action performed when the menu is closed.
    func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    )
}
