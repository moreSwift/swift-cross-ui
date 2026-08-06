import SwiftCrossUI
import WinUI
import UWP

extension KeyboardShortcut {
    func asWinUIKeyboardAccelerator() -> KeyboardAccelerator {
        let accelerator = KeyboardAccelerator()
        accelerator.key = key.asVirtualKey()

        if modifiers.contains(.primary) {
            accelerator.modifiers.rawValue |= VirtualKeyModifiers.control.rawValue
        }
        if modifiers.contains(.secondary) {
            accelerator.modifiers.rawValue |= VirtualKeyModifiers.shift.rawValue
        }
        if modifiers.contains(.tertiary) {
            accelerator.modifiers.rawValue |= VirtualKeyModifiers.menu.rawValue
        }

        return accelerator
    }
}

extension KeyEquivalent {
    func asVirtualKey() -> VirtualKey {
        switch self {
            case .upArrow: .up
            case .downArrow: .down
            case .leftArrow: .left
            case .rightArrow: .right

            case .delete: .back
            case .forwardDelete: .delete
            case .escape: .escape
            case .return: .enter
            case .space: .space
            case .tab: .tab

            case "0": .number0
            case "1": .number1
            case "2": .number2
            case "3": .number3
            case "4": .number4
            case "5": .number5
            case "6": .number6
            case "7": .number7
            case "8": .number8
            case "9": .number9

            case "a", "A": .a
            case "b", "B": .b
            case "c", "C": .c
            case "d", "D": .d
            case "e", "E": .e
            case "f", "F": .f
            case "g", "G": .g
            case "h", "H": .h
            case "i", "I": .i
            case "j", "J": .j
            case "k", "K": .k
            case "l", "L": .l
            case "m", "M": .m
            case "n", "N": .n
            case "o", "O": .o
            case "p", "P": .p
            case "q", "Q": .q
            case "r", "R": .r
            case "s", "S": .s
            case "t", "T": .t
            case "u", "U": .u
            case "v", "V": .v
            case "w", "W": .w
            case "x", "X": .x
            case "y", "Y": .y
            case "z", "Z": .z

            default: fatalError(
                """
                key '\(self.character)' is not currently supported by \
                WinUIBackend; please open an issue at \(Meta.issueReportingURL)
                """
            )
        }
    }
}
