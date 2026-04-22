/// How a backend implements popover menus.
///
/// Regardless of implementation style, backends are expected to implement
/// the methods in ``BackendFeatures/Menus``.
public enum MenuImplementationStyle<Widget, Menu> {
    /// The backend can show popover menus arbitrarily.
    ///
    /// Backends that use this style must implement ``BackendFeatures/PopoverMenus``.
    /// For these backends, ``BackendFeatures/Menus/createPopoverMenu()`` is not
    /// called until after the button is tapped.
    case dynamicPopover(any BackendFeatures.PopoverMenus<Widget, Menu>)
    /// The backend requires menus to be constructed and attached to buttons
    /// ahead of time.
    ///
    /// Backends that use this style must implement
    /// ``BackendFeatures/ButtonMenus``.
    case menuButton(any BackendFeatures.ButtonMenus<Widget, Menu>)
}
