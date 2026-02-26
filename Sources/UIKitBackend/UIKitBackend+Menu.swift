import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public final class Menu {
        var uiMenu: UIMenu?
    }

    public func createPopoverMenu() -> Menu {
        return Menu()
    }

    @available(tvOS 14, *)
    static func buildMenu(
        content: ResolvedMenu,
        label: String,
        identifier: UIMenu.Identifier? = nil
    ) -> UIMenu {
        var currentSection: [UIMenuElement] = []
        var previousSections: [[UIMenuElement]] = []

        for item in content.items {
            switch item {
                case .button(let label, let action):
                    let uiAction =
                        if let action {
                            UIAction(title: label) { _ in action() }
                        } else {
                            UIAction(title: label, attributes: .disabled) { _ in }
                        }
                    currentSection.append(uiAction)
                case .toggle(let label, let value, let onChange):
                    currentSection.append(
                        UIAction(title: label, state: value ? .on : .off) { action in
                            onChange(!action.state.isOn)
                        }
                    )
                case .separator:
                    // UIKit doesn't have explicit separators per se, but instead deals with
                    // sections (actually quite similar to what you can do in SwiftUI with the
                    // Section view). It'll automatically draw separators between sections.
                    previousSections.append(currentSection)
                    currentSection = []
                case .submenu(let submenu):
                    currentSection.append(buildMenu(content: submenu.content, label: submenu.label))
            }
        }

        let children =
            if previousSections.isEmpty {
                // There are no dividers; just return the current section to keep the menu tree flat.
                currentSection
            } else {
                // Create a list of submenus, each with the displayInline option set so that they
                // display as sections with separators.
                (previousSections + [currentSection]).map {
                    UIMenu(title: "", options: .displayInline, children: $0)
                }
            }

        return UIMenu(title: label, identifier: identifier, children: children)
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment _: EnvironmentValues
    ) {
        if #available(iOS 14, macCatalyst 14, tvOS 17, *) {
            menu.uiMenu = UIKitBackend.buildMenu(content: content, label: "")
        } else {
            preconditionFailure("Current OS is too old to support menu buttons.")
        }
    }

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
            if #available(iOS 16, macCatalyst 16, *) {
                buttonWidget.child.preferredMenuElementOrder =
                    switch environment.menuOrder {
                        case .automatic: .automatic
                        case .priority: .priority
                        case .fixed: .fixed
                    }
            }
        } else {
            preconditionFailure("Current OS is too old to support menu buttons.")
        }
    }

    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        #if targetEnvironment(macCatalyst)
            let appDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            appDelegate.menu = submenus
        #else
            // Once keyboard shortcuts are implemented, it might be possible to do them on more
            // platforms than just Mac Catalyst. For now, this is a no-op.
            logger.notice("ignoring \(#function) call")
        #endif
    }
}

extension UIMenuElement.State {
    var isOn: Bool {
        get { self == .on }
        set { self = newValue ? .on : .off }
    }
}
