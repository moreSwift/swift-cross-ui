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

// MARK: Views that can be used as menu items

protocol MenuItemRepresentable: View {
    nonisolated var asMenuItem: MenuItem { get }
}

extension Button: MenuItemRepresentable {
    nonisolated var asMenuItem: MenuItem { .button(self) }
}

extension Text: MenuItemRepresentable {
    nonisolated var asMenuItem: MenuItem { .text(self) }
}

extension Toggle: MenuItemRepresentable {
    nonisolated var asMenuItem: MenuItem { .toggle(self) }
}

extension Divider: MenuItemRepresentable {
    nonisolated var asMenuItem: MenuItem { .separator(self) }
}

@available(iOS 14, macCatalyst 14, tvOS 17, *)
extension Menu: MenuItemRepresentable {
    var asMenuItem: MenuItem { .submenu(self) }
}

extension TupleView1: MenuItemRepresentable where View0: MenuItemRepresentable {
    var asMenuItem: MenuItem { view0.asMenuItem }
}

extension EnvironmentModifier: MenuItemRepresentable where Child: MenuItemRepresentable {
    nonisolated var asMenuItem: MenuItem {
        .modifiedEnvironment(
            { self.body.asMenuItem },
            { self.modification }
        )
    }
}
