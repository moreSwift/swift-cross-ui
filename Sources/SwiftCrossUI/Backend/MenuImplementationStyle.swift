/// How a backend implements popover menus.
///
/// Regardless of implementation style, backends are expected to implement
/// the methods in ``BackendFeatures/MenuButtons``.
///
/// ## See Also
/// - ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``
public enum MenuImplementationStyle<Widget, Menu> {
    /// The backend can show popover menus arbitrarily.
    ///
    /// Backends that use this style must implement ``BackendFeatures/PopoverMenus``.
    /// For these backends, ``BackendFeatures/MenuButtons/createPopoverMenu()`` is not
    /// called until after the button is tapped.
    ///
    /// When returning this from a manual implementation of
    /// ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``, it is recommended to simply
    /// conform your existing backend to ``BackendFeatures/PopoverMenus`` and use `self`
    /// as the associated value:
    ///
    /// ```swift
    /// extension MyBackend: BackendFeatures.PopoverMenus {
    ///     var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
    ///         .dynamicPopover(self)
    ///     }
    ///
    ///     // ...other methods...
    /// }
    /// ```
    ///
    /// ## See Also
    /// - ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``
    /// - ``BackendFeatures/MenuButtons/menuImplementationStyle-136z8`` <!-- default implementation -->
    case dynamicPopover(any BackendFeatures.PopoverMenus<Widget, Menu>)
    /// The backend requires menus to be constructed and attached to buttons
    /// ahead of time.
    ///
    /// Backends that use this style must implement
    /// ``BackendFeatures/AttachedMenus``.
    ///
    /// When returning this from a manual implementation of
    /// ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``, it is recommended to simply
    /// conform your existing backend to ``BackendFeatures/AttachedMenus`` and use `self`
    /// as the associated value:
    ///
    /// ```swift
    /// extension MyBackend: BackendFeatures.AttachedMenus {
    ///     var menuImplementationStyle: MenuImplementationStyle<Widget, Menu> {
    ///         .menuButton(self)
    ///     }
    ///
    ///     // ...other methods...
    /// }
    /// ```
    ///
    /// ## See Also
    /// - ``BackendFeatures/MenuButtons/menuImplementationStyle-4blzf``
    /// - ``BackendFeatures/MenuButtons/menuImplementationStyle-29bja`` <!-- default implementation -->
    case menuButton(any BackendFeatures.AttachedMenus<Widget, Menu>)
}
