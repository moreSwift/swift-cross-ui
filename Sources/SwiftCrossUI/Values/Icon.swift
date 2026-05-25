/// A system icon.
public struct Icon: Hashable, Sendable {
    package enum Kind: Hashable, Sendable {
        case share
        case plus
        case back
        case cut
        case copy
        case paste
        case search
        case custom(_ name: String)
    }

    package let kind: Kind
    package init(kind: Kind) {
        self.kind = kind
    }

    /// A system icon representing a sharing operation.
    public static let share = Icon(kind: .share)
    /// A system icon representing adding an item.
    public static let plus = Icon(kind: .plus)
    /// A system icon representing a backwards navigation.
    public static let back = Icon(kind: .back)
    /// A system icon representing a cutting operation.
    public static let cut = Icon(kind: .cut)
    /// A system icon representing a copying operation.
    public static let copy = Icon(kind: .copy)
    /// A system icon representing a pasting operation.
    public static let paste = Icon(kind: .paste)
    /// A system icon representing a searching operation.
    public static let search = Icon(kind: .search)

    package static func custom(_ name: String) -> Icon {
        Icon(kind: .custom(name))
    }
}
