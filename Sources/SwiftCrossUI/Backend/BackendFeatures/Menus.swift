extension BackendFeatures {
    /// Backend methods for menu buttons.
    ///
    /// - Important: You only need to write a conformance to _one of_
    ///   ``AttachedMenus`` or ``PopoverMenus``, depending on what you use as
    ///   your ``MenuButtons/menuImplementationStyle-4blzf`` (that is, what would work best
    ///   for your backend's underlying UI framework).
    @MainActor
    public protocol MenuButtons<Menu>: Core, Buttons {
        /// The underlying menu type. Can be a wrapper or subclass.
        associatedtype Menu

        /// How the backend handles rendering of menu buttons.
        ///
        /// This affects which menu-related methods are called.
        ///
        /// This requirement is automatically implemented for backends that conform to exactly
        /// one of ``BackendFeatures/PopoverMenus`` or ``BackendFeatures/AttachedMenus``.
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
    public protocol AttachedMenus<Widget, Menu>: MenuButtons {
        /// Sets a button's label and menu.
        ///
        /// Only used when ``BackendFeatures/MenuButtons/menuImplementationStyle`` is
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
    public protocol PopoverMenus<Widget, Menu>: MenuButtons {
        /// Shows the popover menu at a position relative to the given widget.
        ///
        /// Only used when ``BackendFeatures/MenuButtons/menuImplementationStyle`` is
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

extension BackendFeatures.MenuButtons where Self: BackendFeatures.PopoverMenus {
    /// The default implementation of ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``
    /// for backends that implement ``BackendFeatures/PopoverMenus``.
    ///
    /// This simply returns `.dynamicPopover(self)`. You should very rarely have
    /// to override this.
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        .dynamicPopover(self)
    }
}

extension BackendFeatures.MenuButtons where Self: BackendFeatures.AttachedMenus {
    /// The default implementation of ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``
    /// for backends that implement ``BackendFeatures/AttachedMenus``.
    ///
    /// This simply returns `.menuButton(self)`. You should very rarely have
    /// to override this.
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        .menuButton(self)
    }
}

// NB: The default implementations below serve to provide more helpful error messages when
// the two `menuImplementationStyle` implementations above conflict or when neither of them
// can be used -- i.e. when both (or neither) of `PopoverMenus` and `AttachedMenus` are
// conformed to.

extension BackendFeatures.MenuButtons where Self: BackendFeatures.PopoverMenus, Self: BackendFeatures.AttachedMenus {
    @available(
        *, unavailable,
        message: """
        you should only conform to one of 'PopoverMenus' or 'AttachedMenus'. Implement \
        'menuImplementationStyle' manually if conforming to both is intentional
        """
    )
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        fatalError("unavailable default implementation of 'menuImplementationStyle'")
    }
}

extension BackendFeatures.MenuButtons {
    @available(
        *, unavailable,
        message: """
        you need to conform to one of 'PopoverMenus' or 'AttachedMenus' for full 'MenuButtons' conformance
        """
    )
    public var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
        fatalError("unavailable default implementation of 'menuImplementationStyle'")
    }
}
