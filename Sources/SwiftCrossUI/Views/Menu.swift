/// A button that shows a popover menu when clicked.
///
/// Due to technical limitations, the minimum supported OS's for menu buttons in
/// UIKitBackend are iOS 14 and tvOS 17.
public struct Menu {
    /// The menu's label.
    public var label: String
    /// The menu's items.
    public var items: [MenuItem]

    var buttonWidth: Int?

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - label: The menu's label.
    ///   - items: The menu's items.
    public init(_ label: String, @MenuItemsBuilder items: () -> [MenuItem]) {
        self.label = label
        self.items = items()
    }

    /// Resolves the menu to a representation used by backends.
    @MainActor
    func resolve() -> ResolvedMenu.Submenu {
        ResolvedMenu.Submenu(
            label: label,
            content: Self.resolve(items: items)
        )
    }

    @MainActor
    static func resolve(item: MenuItem) -> ResolvedMenu.Item {
        switch item {
            case .button(let button):
                .button(button.label, button.action)
            case .text(let text):
                .button(text.string, nil)
            case .toggle(let toggle):
                .toggle(
                    toggle.label,
                    toggle.active.wrappedValue,
                    onChange: { toggle.active.wrappedValue = $0 }
                )
            case .separator:
                .separator
            case .submenu(let submenu):
                .submenu(submenu.resolve())
            case .modifiedEnvironment(let item, let modification):
                .modifiedEnvironment(resolve(item: item()), modification())
        }
    }

    /// Resolves the menu's items to a representation used by backends.
    @MainActor
    static func resolve(items: [MenuItem]) -> ResolvedMenu {
        ResolvedMenu(items: items.map(resolve(item:)))
    }
}

@available(iOS 14, macCatalyst 14, tvOS 17, *)
extension Menu: TypeSafeView {
    public var body: EmptyView { return EmptyView() }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        MenuStorage()
    }

    func asWidget<Backend: AppBackend>(
        _ children: MenuStorage,
        backend: Backend
    ) -> Backend.Widget {
        return backend.createButton()
    }

    func layoutableChildren<Backend: AppBackend>(
        backend: Backend,
        children: MenuStorage
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: MenuStorage,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // TODO: Look into ways to predict a button's natural size without
        //   updating its content so that computeLayout can be a bit more of
        //   a pure function.

        // Update the button before measuring its natural size
        switch backend.menuImplementationStyle {
            case .dynamicPopover:
                // Our menu button action implementation needs to know the size
                // of the button, but we don't have that yet, so just update it
                // with an empty action and fix it in commit.
                backend.updateButton(
                    widget,
                    label: label,
                    environment: environment,
                    action: {}
                )
            case .menuButton:
                let menu =
                    children.menu.flatMap { $0 as? Backend.Menu }
                    ?? backend.createPopoverMenu()
                children.menu = menu
                backend.updateButton(
                    widget,
                    label: label,
                    menu: menu,
                    environment: environment
                )
        }

        var size = backend.naturalSize(of: widget)
        size.x = buttonWidth ?? size.x
        return ViewLayoutResult.leafView(size: ViewSize(size))
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: MenuStorage,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = layout.size
        backend.setSize(of: widget, to: size.vector)

        switch backend.menuImplementationStyle {
            case .dynamicPopover:
                backend.updateButton(
                    widget,
                    label: label,
                    environment: environment,
                    action: {
                        let content = resolve().content
                        let menu = backend.createPopoverMenu()
                        children.menu = menu
                        backend.updatePopoverMenu(
                            menu,
                            content: content,
                            environment: environment
                        )
                        backend.showPopoverMenu(
                            menu,
                            at: SIMD2(0, LayoutSystem.roundSize(size.height) + 2),
                            relativeTo: widget
                        ) {
                            children.menu = nil
                        }
                    }
                )

                if let menu = children.menu {
                    let content = resolve().content
                    backend.updatePopoverMenu(
                        menu as! Backend.Menu,
                        content: content,
                        environment: environment
                    )
                }
            case .menuButton:
                // We can assume that computeLayout has already run, so children.menu
                // will already be correctly initialized.
                let content = resolve().content
                let menu = children.menu! as! Backend.Menu
                backend.updatePopoverMenu(
                    menu,
                    content: content,
                    environment: environment
                )

                // Even though we update the button in computeLayout (in order
                // for naturalSize to work), we appear to have to update it again
                // in commit; otherwise UIKitBackend users get menu buttons that
                // aren't poppable until the second time that the view gets updated.
                // They also get menu button menus with toggles that only toggle every
                // second time. I'm not sure why any of that happens.
                // TODO: Investigate why the following is needed. It may point us to
                //   some layout system/state management issues.
                backend.updateButton(
                    widget,
                    label: label,
                    menu: menu,
                    environment: environment
                )
        }
    }

    /// A temporary button width solution until arbitrary labels are supported.
    public func _buttonWidth(_ width: Int?) -> Menu {
        var menu = self
        menu.buttonWidth = width
        return menu
    }
}

class MenuStorage: ViewGraphNodeChildren {
    var menu: Any?

    var widgets: [AnyWidget] = []
    var erasedNodes: [ErasedViewGraphNode] = []

    init() {}
}
