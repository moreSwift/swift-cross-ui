/// A generic representation of an application menu, pop-up menu, or context menu.
/// This is what eventually gets passed through to the backend.
///
/// Referred to as 'resolved' because SwiftCrossUI provides some relatively
/// abstract ways to specify menu items, and this is the format that it resolves
/// all menus to eventually.
public struct ResolvedMenu {
    /// The menu's items.
    public var items: [Item]

    /// Creates a ``ResolvedMenu`` instance.
    ///
    /// - Parameter items: The menu's items.
    public init(items: [ResolvedMenu.Item]) {
        self.items = items
    }

    /// A menu item.
    public enum Item {
        /// A button.
        ///
        /// - Parameters:
        ///   - label: The button's label.
        ///   - action: The action to perform when the button is activated. `nil`
        ///     means the button is disabled.
        case button(_ label: String, _ action: (@MainActor () -> Void)?)
        /// A toggle that manages boolean state.
        ///
        /// Usually appears as a checkbox.
        ///
        /// - Parameters:
        ///   - label: The toggle's label.
        ///   - value: The toggle's current state.
        ///   - onChange: Called whenever the user changes the toggle's state.
        case toggle(_ label: String, _ value: Bool, onChange: @MainActor (Bool) -> Void)
        /// A section separator.
        case separator
        /// A named submenu.
        case submenu(Submenu)
        /// A wrapper for a menu item that modifies its environment.
        ///
        /// - Parameters:
        ///   - item: The item to modify the environment of.
        ///   - modification: A function that modifies a given
        ///     `EnvironmentValues` instance.
        indirect case modifiedEnvironment(
            _ item: Item,
            _ modification: (EnvironmentValues) -> EnvironmentValues
        )
    }

    /// A named submenu.
    public struct Submenu {
        /// The label of the submenu's entry in its parent menu.
        public var label: String
        /// The menu displayed when the submenu gets activated.
        public var content: ResolvedMenu

        /// Creates a ``Submenu`` instance.
        ///
        /// - Parameters:
        ///   - label: The label of the submenu's entry in its parent menu.
        ///   - content: The menu displayed when the submenu gets activated.
        public init(label: String, content: ResolvedMenu) {
            self.label = label
            self.content = content
        }
    }
}
