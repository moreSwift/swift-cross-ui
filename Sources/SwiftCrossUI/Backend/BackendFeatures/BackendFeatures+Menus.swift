import Foundation

extension BackendFeatures {
    /// Backend methods for menus.
    ///
    /// - Important: You only need to write a conformance to _one of_
    ///   ``ButtonMenus`` or ``PopoverMenus``, depending on what you use as
    ///   your ``Menus/menuImplementationStyle-4blzf`` (that is, what would work best
    ///   for your backend's underlying UI framework).
    @MainActor
    public protocol Menus<Menu>: Core, Buttons {
        /// The underlying menu type. Can be a wrapper or subclass.
        associatedtype Menu

        /// How the backend handles rendering of menu buttons.
        ///
        /// This affects which menu-related methods are called.
        ///
        /// This requirement is automatically implemented for backends that conform to exactly
        /// one of ``BackendFeatures/PopoverMenus`` or ``BackendFeatures/ButtonMenus``.
        ///
        /// ## See Also
        /// - ``MenuImplementationStyle``
        var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> { get }

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
    public protocol ButtonMenus<Widget, Menu>: Menus {
        /// Sets a button's label and menu.
        ///
        /// Only used when ``BackendFeatures/Menus/menuImplementationStyle`` is
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
    public protocol PopoverMenus<Widget, Menu>: Menus {
        /// Shows the popover menu at a position relative to the given widget.
        ///
        /// Only used when ``BackendFeatures/Menus/menuImplementationStyle`` is
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

extension BackendFeatures.Menus where Self: BackendFeatures.PopoverMenus {
    /// The default implementation of ``BackendFeatures/Menus/menuImplementationStyle-4blzf``
    /// for backends that implement ``BackendFeatures/PopoverMenus``.
    ///
    /// This simply returns `.dynamicPopover(self)`. You should very rarely have
    /// to override this.
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        .dynamicPopover(self)
    }
}

extension BackendFeatures.Menus where Self: BackendFeatures.ButtonMenus {
    /// The default implementation of ``BackendFeatures/Menus/menuImplementationStyle-4blzf``
    /// for backends that implement ``BackendFeatures/ButtonMenus``.
    ///
    /// This simply returns `.menuButton(self)`. You should very rarely have
    /// to override this.
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        .menuButton(self)
    }
}
