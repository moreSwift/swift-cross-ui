import AppKit
import SwiftCrossUI

extension AppKitBackend: BackendFeatures.PopoverMenus {
    public typealias Menu = NSMenu
    
    public func createPopoverMenu() -> Menu {
        return NSMenu()
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.appearance = environment.colorScheme.nsAppearance
        menu.items = content.items.map {
            Self.renderMenuItem($0, environment: environment)
        }
    }

    public func showPopoverMenu(
        _ menu: Menu, at position: SIMD2<Int>, relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        // NSMenu.popUp(position:at:in:) blocks until the pop up is closed, and has to
        // run on the main thread, so I'm not exactly sure how it doesn't break things,
        // but it hasn't broken anything yet.
        menu.popUp(
            positioning: nil,
            at: NSPoint(x: CGFloat(position.x + 2), y: CGFloat(position.y + 8)),
            in: widget
        )
        handleClose()
    }
}
