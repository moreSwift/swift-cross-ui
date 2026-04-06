import Foundation

extension AppBackend {
    // TODO: Factor out `menuImplementationStyle` and rely on conformances instead

    /// Backend methods for menus.
    ///
    /// - Important: You only need to write a conformance to _one of_
    ///   ``ButtonMenus`` or ``PopoverMenus``, depending on what you use as
    ///   your ``MenuBase/menuImplementationStyle`` (that is, what would work best
    ///   for your backend's underlying UI framework).
    public typealias Menus = ButtonMenus & PopoverMenus

    /// Backend methods for basic menu handling.
    @MainActor
    public protocol MenuBase<Menu>: Core {
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

    /// Backend methods for menus that are simply attached to an existing
    /// button widget.
    @MainActor
    public protocol ButtonMenus: MenuBase, Buttons {
        /// Sets a button's label and menu.
        ///
        /// Only used when ``AppBackend/MenuBase/menuImplementationStyle`` is
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

    /// Backend methods for menus which need a separate widget to be created.
    @MainActor
    public protocol PopoverMenus: MenuBase {
        /// Shows the popover menu at a position relative to the given widget.
        ///
        /// Only used when ``AppBackend/MenuBase/menuImplementationStyle`` is
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
}

// MARK: Default Implementations

extension AppBackend.MenuBase {
    public func createPopoverMenu() -> Menu {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}

extension AppBackend.ButtonMenus {
    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}

extension AppBackend.PopoverMenus {
    public func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}
