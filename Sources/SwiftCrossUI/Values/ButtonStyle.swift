/// A type that applies a standard base button type to the backend's representation.
///
/// You can use `BaseButtonStyle` to change what canvas a backend uses before drawing your
/// ``Button`` with your ``ButtonStyle`` on top.
public struct BaseButtonStyle: Hashable, Sendable {
    package enum Kind {
        case bordered
        case plain
        case borderless
    }

    package var kind: Kind

    /// A base button style that applies the standard border style based on the button’s context.
    @available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *)
    public static let bordered = Self(kind: .bordered)
    /// A base button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    public static let plain = Self(kind: .plain)
    /// A button style that doesn’t apply a border.
    ///
    /// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
    /// due to the SwiftUI borderless behavior on mac being stupid.
    /// The only difference is a default foreground color of gray being applied.
    public static let borderless = Self(kind: .borderless)
}

/// A protocol allowing buttons to tell the backend what base canvas to use before drawing
/// a button label and ``ButtonStyle`` on top.
@MainActor
public protocol _InternalButtonStyle {
    /// The base canvans look of a button.
    var baseButtonStyle: BaseButtonStyle { get }
}

extension _InternalButtonStyle {
    public var baseButtonStyle: BaseButtonStyle { .plain }
}

/// A type that applies standard interaction behavior and a custom appearance to all buttons within a view hierarchy.
@MainActor
public protocol ButtonStyle: _InternalButtonStyle {
    /// A view that represents the body of a button.
    associatedtype Body: View
    /// Creates a view that represents the body of a button.
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

extension ButtonStyle {
    /// The properties of a button.
    public typealias Configuration = ButtonStyleConfiguration
}

extension ButtonStyle where Self == PlainButtonStyle {
    /// A button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    public static var plain: PlainButtonStyle { PlainButtonStyle() }
}

extension ButtonStyle where Self == BorderedButtonStyle {
    /// A button style that applies the standard border style based on the button’s context.
    public static var bordered: BorderedButtonStyle { BorderedButtonStyle() }
}

extension ButtonStyle where Self == BorderlessButtonStyle {
    /// A button style that doesn’t apply a border.
    ///
    /// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
    /// due to the SwiftUI borderless behavior on mac being stupid.
    /// The only difference is a default foreground color of gray being applied.
    public static var borderless: BorderlessButtonStyle { BorderlessButtonStyle() }
}

/// The properties of a button.
public struct ButtonStyleConfiguration {
    /// A Boolean that indicates whether the user is currently pressing the button.
    public let isPressed: Bool
    /// A view that's rendered as the label of a button.
    public let label: Label
    // TODO: Add button role support (ie .destructive, .cancel,...)
    // public let role: ButtonRole
    
    /// A type-erased label of a button.
    public struct Label: View {
        init<V: View>(body: V) {
            self.body = AnyView(body)
        }
        public let body: AnyView
    }
}

/// A button style that applies the standard border style based on the button’s context.
public struct BorderedButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// A button style that doesn’t apply a border.
///
/// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
/// due to the SwiftUI borderless behavior on mac being stupid.
/// The only difference is a default foreground color of gray being applied.
public struct BorderlessButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// A button style that doesn’t style or decorate its content while idle,
/// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
public struct PlainButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension BorderedButtonStyle: _InternalButtonStyle {
    public var baseButtonStyle: BaseButtonStyle { .bordered }
}
