/// The information passed by ``View/focused(_:)`` to a backend.
public struct FocusData {
    /// The type of the Value indicating focus location.
    let type: any Hashable.Type
    /// The value the ``FocusState`` should have, when the view is focused.
    private let match: any Hashable
    /// A function to set the ``FocusState`` to ``match``.
    public let set: () -> Void
    /// A function to set the ``FocusState`` to unfocused.
    public let reset: () -> Void

    /// Whether the backend should remove focus from the view.
    public let shouldUnfocus: Bool
    /// Wheter the the ``FocusState``'s value matches ``match``.
    public let matches: Bool

    public init(
        type: any Hashable.Type,
        match: any Hashable,
        set: @escaping () -> Void,
        reset: @escaping () -> Void,
        matches: Bool,
        shouldUnfocus: Bool
    ) {
        self.type = type
        self.match = match
        self.set = set
        self.reset = reset
        self.matches = matches
        self.shouldUnfocus = shouldUnfocus
    }
}

extension FocusData: Hashable {
    public static func == (lhs: FocusData, rhs: FocusData) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type).hashValue)
        hasher.combine(match)
    }
}
