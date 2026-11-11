import SwiftCrossUI
import AndroidKit
import SwiftJava

// swiftlint:disable force_try
extension AndroidKit.PopupMenu {
    // Workaround for the fact that you can't put @JavaMethod inits in extensions
    static func construct(
        _ context: AndroidKit.Context!,
        _ anchor: AndroidKit.View!,
        environment: JNIEnvironment!
    ) -> AndroidKit.PopupMenu {
        try! Self.dynamicJavaNewObject(in: environment, arguments: context, anchor)
    }

    @JavaMethod
    func getMenu() -> AndroidKit.Menu!
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomMenuItemClickListener",
    implements: AndroidKit.MenuItem.OnMenuItemClickListener.self
)
class CustomMenuItemClickListener: JavaObject {
    @JavaMethod
    convenience init(
        _ action: SwiftAction!,
        environment: JNIEnvironment? = nil
    )
}

// Note: This implementation relies on the fact that SwiftCrossUI::Menu.commit always calls
// updatePopoverMenu before calling updateButton. If that is changed,
// AndroidBackend.Menu.realizeMenu needs to be moved to be called in updatePopoverMenu instead of
// updateButton. I'm not including it in both to avoid duplicating work.
extension AndroidBackend: BackendFeatures.AttachedMenus {
    @MainActor
    public final class Menu {
        private var popupMenu: AndroidKit.PopupMenu? = nil
        private var anchor: AndroidKit.View? = nil

        var content = ResolvedMenu(items: [])

        func setView(_ view: AndroidKit.View, environment: EnvironmentValues) {
            let popupMenu =
                if
                    view.javaThisOptional == self.anchor?.javaThisOptional,
                    let popupMenu = self.popupMenu
                {
                    popupMenu
                } else {
                    AndroidKit.PopupMenu.construct(activity, view, environment: env)
                }

            self.popupMenu = popupMenu
            self.anchor = view

            Self.realizeMenu(
                menu: popupMenu.getMenu(),
                items: content.items,
                environment: environment
            )
        }

        private static func realizeMenu(
            menu: AndroidKit.Menu,
            items: [ResolvedMenu.Item],
            environment: EnvironmentValues
        ) {
            menu.clear()

            var groupId: Int32 = 1

            for (index, item) in items.enumerated() {
                addMenuItem(
                    item,
                    to: menu,
                    index: index,
                    environment: environment,
                    groupId: &groupId
                )
            }
        }

        private static func addMenuItem(
            _ item: ResolvedMenu.Item,
            to menu: AndroidKit.Menu,
            index: Int,
            environment: EnvironmentValues,
            groupId: inout Int32
        ) {
            switch item {
                case .button(let label, let action):
                    let menuItem = menu.add(
                        groupId,
                        0,
                        Int32(index),
                        charSequence(from: label)
                    )
                    .setEnabled(environment.isEnabled)!

                    if environment.isEnabled {
                        let onClick = CustomMenuItemClickListener(
                            SwiftAction(environment: env) { action?() },
                            environment: env
                        )

                        _ = menuItem.setOnMenuItemClickListener(
                            onClick.as(MenuItem.OnMenuItemClickListener.self)
                        )
                    }
                case .toggle(let label, let value, let onChange):
                    let menuItem = menu.add(
                        groupId,
                        0,
                        Int32(index),
                        charSequence(from: label)
                    )
                    .setEnabled(environment.isEnabled)
                    .setCheckable(true)
                    .setChecked(value)!

                    if environment.isEnabled {
                        let onClick = CustomMenuItemClickListener(
                            SwiftAction(environment: env) { onChange(!value) },
                            environment: env
                        )

                        _ = menuItem.setOnMenuItemClickListener(
                            onClick.as(MenuItem.OnMenuItemClickListener.self)
                        )
                    }
                case .separator:
                    menu.setGroupDividerEnabled(true)
                    groupId += 1
                case .submenu(let resolvedSubmenu):
                    let submenu = menu.addSubMenu(
                        groupId,
                        0,
                        Int32(index),
                        charSequence(from: resolvedSubmenu.label)
                    )!

                    realizeMenu(
                        menu: submenu.as(AndroidKit.Menu.self),
                        items: resolvedSubmenu.content.items,
                        environment: environment
                    )
                case .modifiedEnvironment(let innerItem, let modification):
                    addMenuItem(
                        innerItem,
                        to: menu,
                        index: index,
                        environment: modification(environment),
                        groupId: &groupId
                    )
            }
        }

        func show() {
            popupMenu?.show()
        }
    }

    public func createPopoverMenu() -> AndroidBackend.Menu {
        AndroidBackend.Menu()
    }

    public func updatePopoverMenu(
        _ menu: AndroidBackend.Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.content = content
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        menu.setView(
            button,
            environment: environment
        )

        self.updateSimpleButton(
            button,
            label: label,
            environment: environment,
            action: menu.show
        )
    }
}
