import AppKit
import SwiftCrossUI

@MainActor
enum MenuBar {
    // You may notice that multiple different base types are used in the
    // action selectors of the various menu items. This is because the
    // selectors get sent to the app's first responder at the time of
    // the command getting sent. If the first responder doesn't have a
    // method matching the selector, then AppKit automatically disables
    // the corresponding menu item.

    private static var appMenu: (appMenu: NSMenu, servicesMenu: NSMenu) {
        // The first menu item is special and always takes on the name of the app.
        let appName = ProcessInfo.processInfo.processName

        let servicesMenu = NSMenu(title: "Services")
        let servicesMenuItem = NSMenuItem(title: "Services", action: nil)
        servicesMenuItem.submenu = servicesMenu

        let appMenu = NSMenu(
            title: appName,
            items: [
                NSMenuItem(
                    title: "About \(appName)",
                    action: #selector(NSApplication.orderFrontStandardAboutPanel(_:))
                ),
                NSMenuItem.separator(),
                servicesMenuItem,
                NSMenuItem.separator(),
                NSMenuItem(
                    title: "Hide \(appName)",
                    action: #selector(NSApplication.hide(_:)),
                    keyEquivalent: ("h", .command)
                ),
                NSMenuItem(
                    title: "Hide Others",
                    action: #selector(NSApplication.hideOtherApplications(_:)),
                    keyEquivalent: ("h", [.option, .command])
                ),
                NSMenuItem(
                    title: "Show All",
                    action: #selector(NSApplication.unhideAllApplications(_:))
                ),
                NSMenuItem.separator(),
                NSMenuItem(
                    title: "Quit \(appName)",
                    action: #selector(NSApplication.terminate(_:)),
                    keyEquivalent: ("q", .command)
                ),
            ]
        )

        return (appMenu, servicesMenu)
    }

    private static var fileMenu: NSMenu {
        NSMenu(
            title: "File",
            items: [
                NSMenuItem(
                    title: "Close",
                    action: #selector(NSWindow.performClose(_:)),
                    keyEquivalent: ("w", .command)
                )
            ]
        )
    }

    private static var editMenu: NSMenu {
        NSMenu(
            title: "Edit",
            items: [
                // NB: We've failed to find which class (if any) `undo:` and `redo: are supposed
                // to come from, and the following Apple documentation article makes it sound
                // like they're just stringly-typed ObjC messages:
                // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UndoArchitecture/Articles/AppKitUndo.html
                //
                // The double parentheses are needed to silence compiler warnings.
                NSMenuItem(
                    title: "Undo",
                    action: Selector(("undo:")),
                    keyEquivalent: ("z", .command)
                ),
                NSMenuItem(
                    title: "Redo",
                    action: Selector(("redo:")),
                    keyEquivalent: ("z", [.command, .shift])
                ),

                NSMenuItem.separator(),

                NSMenuItem(
                    title: "Cut",
                    action: #selector(NSText.cut(_:)),
                    keyEquivalent: ("x", .command)
                ),
                NSMenuItem(
                    title: "Copy",
                    action: #selector(NSText.copy(_:)),
                    keyEquivalent: ("c", .command)
                ),
                NSMenuItem(
                    title: "Paste",
                    action: #selector(NSText.paste(_:)),
                    keyEquivalent: ("v", .command)
                ),
                NSMenuItem(
                    title: "Delete",
                    action: #selector(NSText.delete(_:))
                ),
                NSMenuItem(
                    title: "Select All",
                    action: #selector(NSText.selectAll(_:)),
                    keyEquivalent: ("a", .command)
                ),
            ]
        )
    }

    private static var viewMenu: NSMenu {
        // AppKit adds the default menu items for us.
        NSMenu(title: "View")
    }

    private static var windowMenu: NSMenu {
        NSMenu(
            title: "Window",
            items: [
                // AppKit automatically adds the Command+M shortcut to Minimize. (This is the
                // only menu item I know of where this happens.)
                NSMenuItem(
                    title: "Minimize",
                    action: #selector(NSWindow.performMiniaturize(_:))
                ),
                NSMenuItem(
                    title: "Zoom",
                    action: #selector(NSWindow.performZoom(_:))
                ),

                NSMenuItem.separator(),
                NSMenuItem(
                    title: "Bring All to Front",
                    action: #selector(NSApplication.arrangeInFront(_:))
                ),
            ]
        )
    }

    private static var helpMenu: NSMenu {
        NSMenu(title: "Help")
    }

    static func setUpMenuBar(extraMenus: [NSMenuItem]) {
        let (appMenu, servicesMenu) = MenuBar.appMenu
        let fileMenu = MenuBar.fileMenu
        let editMenu = MenuBar.editMenu
        let viewMenu = MenuBar.viewMenu
        let windowMenu = MenuBar.windowMenu
        let helpMenu = MenuBar.helpMenu

        var uniqueMenus: [NSMenuItem] = []
        do {
            let defaultMenus = [fileMenu, editMenu, viewMenu, windowMenu, helpMenu]
            for menu in extraMenus {
                // To merge app-defined File, Edit, View, Window, and Help menus with our own, we
                // check if the menu titles match. If they do, we move every item from the user's
                // menu to our own.
                if let submenu = menu.submenu,
                   let matchingMenu = defaultMenus.first(where: { $0.title == menu.title })
                {
                    let items = submenu.items
                    submenu.removeAllItems()
                    matchingMenu.items += items
                } else {
                    uniqueMenus.append(menu)
                }
            }
        }

        let menuBar = NSMenu()
        for menu in [appMenu, fileMenu, editMenu, viewMenu] {
            let menuItem = NSMenuItem()
            menuItem.submenu = menu
            menuBar.addItem(menuItem)
        }
        menuBar.items += uniqueMenus
        for menu in [windowMenu, helpMenu] {
            let menuItem = NSMenuItem()
            menuItem.submenu = menu
            menuBar.addItem(menuItem)
        }

        NSApplication.shared.servicesMenu = servicesMenu
        NSApplication.shared.windowsMenu = windowMenu
        NSApplication.shared.helpMenu = helpMenu
        NSApplication.shared.mainMenu = menuBar
    }
}

extension NSMenuItem {
    convenience init(
        title: String,
        action selector: Selector?,
        keyEquivalent: (key: String, modifiers: NSEvent.ModifierFlags)? = nil
    ) {
        self.init(title: title, action: selector, keyEquivalent: keyEquivalent?.key ?? "")
        if let modifiers = keyEquivalent?.modifiers {
            self.keyEquivalentModifierMask = modifiers
        }
    }
}

extension NSMenu {
    convenience init(title: String, items: [NSMenuItem]) {
        self.init(title: title)
        self.items = items
    }
}
