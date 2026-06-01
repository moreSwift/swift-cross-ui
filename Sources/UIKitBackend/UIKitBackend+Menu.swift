import SwiftCrossUI
import UIKit


extension UIKitBackend {
    @available(iOS 13, *)
    public final class Menu {
        var uiMenu: UIMenu?
    }
    
    @available(iOS 13, *)
    public func createPopoverMenu() -> Menu {
        return Menu()
    }
    
    @available(iOS 13, *)
    @available(tvOS 14, *)
    static func buildMenu(
        content: ResolvedMenu,
        label: String,
        identifier: UIMenu.Identifier? = nil
    ) -> UIMenu {
        let children = content.items.map { (item) -> UIMenuElement in
            switch item {
                case .button(let label, let action):
                    if let action {
                        UIAction(title: label) { _ in action() }
                    } else {
                        UIAction(title: label, attributes: .disabled) { _ in }
                    }
                case .submenu(let submenu):
                    buildMenu(content: submenu.content, label: submenu.label)
            }
        }

        return UIMenu(title: label, identifier: identifier, children: children)
    }
    
    @available(iOS 13, *)
    public func updatePopoverMenu(
        _ menu: Menu, content: ResolvedMenu, environment _: EnvironmentValues
    ) {
        if #available(iOS 14, macCatalyst 14, tvOS 17, *) {
            menu.uiMenu = UIKitBackend.buildMenu(content: content, label: "")
        } else {
            preconditionFailure("Current OS is too old to support menu buttons.")
        }
    }
    
    @available(iOS 13, *)
    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        if #available(iOS 14, macCatalyst 14, tvOS 17, *) {
            let buttonWidget = button as! ButtonWidget
            buttonWidget.child.isEnabled = environment.isEnabled
            setButtonTitle(buttonWidget, label, environment: environment)
            buttonWidget.child.menu = menu.uiMenu
            buttonWidget.child.showsMenuAsPrimaryAction = true
        } else {
            preconditionFailure("Current OS is too old to support menu buttons.")
        }
    }
    
    @available(iOS 13, *)
    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        #if targetEnvironment(macCatalyst)
            let appDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            appDelegate.menu = submenus
        #else
            // Once keyboard shortcuts are implemented, it might be possible to do them on more
            // platforms than just Mac Catalyst. For now, this is a no-op.
            print("UIKitBackend: ignoring \(#function) call")
        #endif
    }
}
