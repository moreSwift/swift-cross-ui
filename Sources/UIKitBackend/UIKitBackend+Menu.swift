import SwiftCrossUI
import UIKit

extension UIKitBackend {
    private enum RenderedMenuItem {
        case item(UIMenuElement)
        case separator
    }

    @available(tvOS 14, *)
    private static func renderMenuItem(
        _ item: ResolvedMenu.Item,
        environment: EnvironmentValues
    ) -> RenderedMenuItem {
        switch item {
            case .button(let label, let action):
                if let action, environment.isEnabled {
                    .item(UIAction(title: label) { _ in action() })
                } else {
                    .item(UIAction(title: label, attributes: .disabled) { _ in })
                }
            case .toggle(let label, let value, let onChange):
                .item(
                    UIAction(
                        title: label,
                        attributes: environment.isEnabled ? [] : .disabled,
                        state: value ? .on : .off
                    ) { action in
                        onChange(!action.state.isOn)
                    }
                )
            case .separator:
                .separator
            case .submenu(let submenu):
                .item(
                    buildMenu(
                        content: submenu.content,
                        label: submenu.label,
                        environment: environment
                    )
                )
            case .modifiedEnvironment(let item, let modification):
                renderMenuItem(
                    item,
                    environment: modification(environment)
                )
        }
    }

    @available(tvOS 14, *)
    static func buildMenu(
        content: ResolvedMenu,
        label: String,
        identifier: UIMenu.Identifier? = nil,
        environment: EnvironmentValues
    ) -> UIMenu {
        var currentSection: [UIMenuElement] = []
        var previousSections: [[UIMenuElement]] = []

        for item in content.items {
            switch renderMenuItem(item, environment: environment) {
                case .item(let uiMenuElement):
                    currentSection.append(uiMenuElement)
                case .separator:
                    // UIKit doesn't have explicit separators per se, but instead deals with
                    // sections (actually quite similar to what you can do in SwiftUI with the
                    // Section view). It'll automatically draw separators between sections.
                    previousSections.append(currentSection)
                    currentSection = []
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
}

@available(iOS 14, macCatalyst 14, tvOS 17, *)
extension UIKitBackend: BackendFeatures.AttachedMenus {
    public final class Menu {
        var uiMenu: UIMenu?
    }

    public func createPopoverMenu() -> Menu {
        return Menu()
    }
    
    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.uiMenu = UIKitBackend.buildMenu(
            content: content,
            label: "",
            environment: environment
        )
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
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
    }
}

// Once keyboard shortcuts are implemented, it might be possible to do them on
// more platforms than just Mac Catalyst. For now, we only conform to the
// protocol when built for Catalyst.
#if targetEnvironment(macCatalyst)
    extension UIKitBackend: BackendFeatures.ApplicationMenus {
        public func setApplicationMenu(
            _ submenus: [ResolvedMenu.Submenu],
            environment: EnvironmentValues
        ) {
            let appDelegate = UIApplication.shared.delegate as! ApplicationDelegate
            appDelegate.menu = submenus
            appDelegate.environment = environment
        }
    }
#endif

extension UIMenuElement.State {
    var isOn: Bool {
        get { self == .on }
        set { self = newValue ? .on : .off }
    }
}
