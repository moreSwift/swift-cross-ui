import Foundation
import SwiftCrossUI

// A lightweight wrapper holding resolved menu content
public final class ComposeMenu {
    var content: ResolvedMenu?
    init() {}
}

extension AndroidComposeBackend: BackendFeatures.AttachedMenus {
    public typealias Menu = ComposeMenu

    public func createPopoverMenu() -> ComposeMenu {
        ComposeMenu()
    }

    public func updatePopoverMenu(
        _ menu: ComposeMenu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.content = content
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        menu: ComposeMenu,
        environment: EnvironmentValues
    ) {
        try? bridge.setProperty(id: button, key: "label", value: label)
        // Encode menu items as newline-separated "label|action_id" pairs
        if let items = menu.content?.items {
            let encoded = items.compactMap { item -> String? in
                guard case .button(let title, _) = item else { return nil }
                return title
            }.joined(separator: "\n")
            try? bridge.setProperty(id: button, key: "menuItems", value: encoded)
        }
        handlers[button, default: EventHandlers()].onClick = nil
    }
}
