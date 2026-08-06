import CGtk
import Gtk
import SwiftCrossUI

extension KeyboardShortcut {
    private func asGtkShortcutTrigger() -> OpaquePointer {
        var gdkModifiers = GDK_NO_MODIFIER_MASK
        if modifiers.contains(.primary) {
            #if os(macOS)
                gdkModifiers.rawValue |= GDK_META_MASK.rawValue // "maps to Command on macOS"
            #else
                gdkModifiers.rawValue |= GDK_CONTROL_MASK.rawValue
            #endif
        }
        if modifiers.contains(.secondary) {
            gdkModifiers.rawValue |= GDK_SHIFT_MASK.rawValue
        }
        if modifiers.contains(.tertiary) {
            gdkModifiers.rawValue |= GDK_ALT_MASK.rawValue
        }

        return gtk_keyval_trigger_new(
            key.character.unicodeScalars.first!.value,
            gdkModifiers
        )
    }

    func add(to widget: Widget) {
        let shortcut = gtk_shortcut_new(
            self.asGtkShortcutTrigger(),
            gtk_shortcut_action_parse_string("activate")
        )

        let shortcutController = gtk_shortcut_controller_new()
        gtk_shortcut_controller_set_scope(
            shortcutController,
            GTK_SHORTCUT_SCOPE_MANAGED
        )
        gtk_shortcut_controller_add_shortcut(
            shortcutController,
            shortcut
        )

        gtk_widget_add_controller(widget.widgetPointer, shortcutController)
    }
}
