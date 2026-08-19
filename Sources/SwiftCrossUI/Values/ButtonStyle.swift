/// A type that applies standard interaction behavior and a custom appearance to all buttons within a view hierarchy.
public struct ButtonStyle: Hashable, Sendable {
    package enum Kind {
        case bordered
        case plain
        case borderless
    }

    package var kind: Kind

    /// A button style that applies the standard border style based on the button’s context.
    @available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *)
    public static let bordered = Self(kind: .bordered)
    /// A button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    public static let plain = Self(kind: .plain)
    /// A button style that doesn’t apply a border.
    ///
    /// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
    /// due to the SwiftUI borderless behavior on mac being stupid.
    /// The only difference is a default foreground color of gray being applied.
    public static let borderless = Self(kind: .borderless)
}

extension ButtonStyle: CustomStringConvertible {
    public var description: String {
        "\(self.kind)"
    }
}
