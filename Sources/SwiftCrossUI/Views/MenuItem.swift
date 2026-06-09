/// An item of a ``Menu`` or ``CommandMenu``.
public enum MenuItem {
    /// A button.
    case button(Button)
    /// Text.
    case text(Text)
    /// A toggle.
    case toggle(Toggle)
    /// A separator.
    case separator(Divider)
    /// A submenu.
    case submenu(Menu)
    /// A menu item with an environment modifier.
    ///
    /// We can't directly store the environment modifier because that would need
    /// a generic in order for us to tease things apart again, so we store
    /// closures that give us the values we need. We can't precompute the values
    /// themselves because that would require ``MenuItemsBuilder`` to be `@MainActor`.
    case modifiedEnvironment(
        @MainActor () -> MenuItem,
        @MainActor () -> (EnvironmentValues) -> EnvironmentValues
    )
}
