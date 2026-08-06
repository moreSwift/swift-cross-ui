import AppKit
import SwiftCrossUI

extension KeyboardShortcut {
    func asAppKitKeyEquivalent() -> (String, NSEvent.ModifierFlags) {
        let string = String(key.character)

        var modifierFlags = NSEvent.ModifierFlags()
        if modifiers.contains(.primary) {
            modifierFlags.insert(.command)
        }
        if modifiers.contains(.secondary) {
            modifierFlags.insert(.shift)
        }
        if modifiers.contains(.tertiary) {
            modifierFlags.insert(.option)
        }

        return (string, modifierFlags)
    }
}
