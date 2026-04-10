/// A command menu.
public struct CommandMenu {
    /// The menu's name.
    var name: String
    /// The menu's contents.
    var content: [MenuItem]

    /// Creates a command menu.
    ///
    /// - Parameters:
    ///   - name: The menu's name.
    ///   - content: The menu's contents.
    public init(
        _ name: String,
        @MenuItemsBuilder content: () -> [MenuItem]
    ) {
        self.name = name
        self.content = content()
    }

    /// Creates a command menu.
    ///
    /// - Parameters:
    ///   - name: The menu's name.
    ///   - content: The menu's contents.
    init(name: String, content: [MenuItem]) {
        self.name = name
        self.content = content
    }

    /// Resolves the menu to a representation used by backends.
    @MainActor
    func resolve() -> ResolvedMenu.Submenu {
        ResolvedMenu.Submenu(
            label: name,
            content: Menu.resolve(items: content)
        )
    }
}
