/// How a backend implements popover menus.
///
/// Regardless of implementation style, backends are expected to implement
/// ``BackendFeatures/MenuBase/createPopoverMenu()``,
/// ``BackendFeatures/MenuBase/updatePopoverMenu(_:content:environment:)``, and
/// ``BackendFeatures/Buttons/updateButton(_:label:environment:action:)``.
public enum MenuImplementationStyle {
    /// The backend can show popover menus arbitrarily.
    ///
    /// Backends that use this style must implement
    /// ``BackendFeatures/PopoverMenus/showPopoverMenu(_:at:relativeTo:closeHandler:)``. For
    /// these backends, ``BackendFeatures/MenuBase/createPopoverMenu()`` is not called
    /// until after the button is tapped.
    case dynamicPopover
    /// The backend requires menus to be constructed and attached to buttons
    /// ahead of time.
    ///
    /// Backends that use this style must implement
    /// ``BackendFeatures/ButtonMenus/updateButton(_:label:menu:environment:)``.
    case menuButton
}
