/// An icon.
public struct Icon: Hashable, Sendable {
    @_spi(Backends) public enum Kind: Hashable, Sendable {
        /// Represents a system-adaptive icon.
        case system(SystemIcon)

        // TODO: Add a `crossPlatform` case here
    }


    /// A set of system-adaptive icons, a limited set of icons for developers
    /// who want to create an absolutely native experience.
    @_spi(Backends) public enum SystemIconKind: Hashable, Sendable {
        case share
        case plus
        case back
        case cut
        case copy
        case paste
        case search
    }

    @_spi(Backends) public let kind: Kind
    init(kind: Kind) {
        self.kind = kind
    }

    /// A system icon.
    public struct SystemIcon: Hashable, Sendable {
        @_spi(Backends) public enum Storage: Hashable, Sendable {
            case builtin(SystemIconKind)
            case custom(String)
        }

        @_spi(Backends) public var storage: Storage
        init(storage: Storage) {
            self.storage = storage
        }

        init(kind: SystemIconKind) {
            self.storage = .builtin(kind)
        }

        /// A system icon representing a sharing operation.
        public static let share = Self(kind: .share)
        /// A system icon representing adding an item.
        public static let plus = Self(kind: .plus)
        /// A system icon representing a backwards navigation.
        public static let back = Self(kind: .back)
        /// A system icon representing a cutting operation.
        public static let cut = Self(kind: .cut)
        /// A system icon representing a copying operation.
        public static let copy = Self(kind: .copy)
        /// A system icon representing a pasting operation.
        public static let paste = Self(kind: .paste)
        /// A system icon representing a searching operation.
        public static let search = Self(kind: .search)

        /// Creates a custom system icon that uses a default identifier, or a platform-specific
        /// identifier if provided.
        public static func custom(_ identifier: String) -> Self {
            return Self(storage: .custom(identifier))
        }
    }

    public static func system(_ icon: SystemIcon) -> Icon {
        Self(kind: .system(icon))
    }
}
