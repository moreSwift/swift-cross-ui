/// A keyboard shortcut.
public struct KeyboardShortcut: Hashable, Sendable {
    public var key: KeyEquivalent
    public var modifiers: EventModifiers

    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .primary) {
        self.key = key
        self.modifiers = modifiers
    }

    /// The "cancel" keyboard shortcut, consisting of the escape key with no
    /// modifiers.
    public static let cancelAction = Self(.escape, modifiers: [])
    /// The "default" keyboard shortcut, consisting of the return/enter key with
    /// no modifiers.
    public static let defaultAction = Self(.return, modifiers: [])
}

/// A set of key modifiers.
public struct EventModifiers: OptionSet, Hashable, Sendable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// The primary modifier.
    ///
    /// This corresponds to the command key on Apple platforms, and the control
    /// key on other platforms.
    public static let primary = Self(rawValue: 1 << 0)
    /// The secondary modifier.
    ///
    /// This corresponds to the shift key on all platforms.
    public static let secondary = Self(rawValue: 1 << 1)
    /// The tertiary modifier.
    ///
    /// This corresponds to the option key on Apple platforms, and the alt key
    /// on other platforms.
    public static let tertiary = Self(rawValue: 1 << 2)
}

/// A non-modifier key on the keyboard that can be combined with modifier keys
/// to specify a keyboard shortcut.
public struct KeyEquivalent: Hashable, Sendable {
    /// The character associated with this key.
    public var character: Character
    public init(_ character: Character) {
        self.character = character
    }

    /// The up arrow key (U+F700).
    public static let upArrow = Self("\u{f700}")
    /// The down arrow key (U+F701).
    public static let downArrow = Self("\u{f701}")
    /// The left arrow key (U+F702).
    public static let leftArrow = Self("\u{f702}")
    /// The right arrow key (U+F703).
    public static let rightArrow = Self("\u{f703}")

    /// The delete/backspace key (U+0008).
    ///
    /// - Important: Most non-Apple platforms call this key "backspace" -- if
    ///   you're looking for the forward delete key, see ``forwardDelete``.
    public static let delete = Self("\u{08}")
    /// The forward delete key (U+F728).
    public static let forwardDelete = Self("\u{f728}")
    /// The escape key (U+001B).
    public static let escape = Self("\u{1b}")
    /// The return/enter key (U+000D).
    public static let `return` = Self("\u{0d}")
    /// The space key (U+0020).
    public static let space = Self("\u{20}")
    /// The tab key (U+0009).
    public static let tab = Self("\u{09}")

    /// The delete/backspace key (U+0008).
    ///
    /// Equivalent to ``delete``.
    public static let backspace = Self.delete
    /// The return/enter key (U+000D).
    ///
    /// Equivalent to ``return``.
    public static let enter = Self.return
}

extension KeyEquivalent: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(value)
    }
}
