/// The result of a call to ``View/computeLayout(_:children:proposedSize:environment:backend:)``.
public struct ViewLayoutResult {
    /// The size that the view has chosen for itself based off of the proposed view size.
    public var size: ViewSize
    /// Whether the view participates in stack layouts when empty (i.e. has its own spacing).
    ///
    /// This will be removed once we properly support dynamic alignment and spacing.
    public var participateInStackLayoutsWhenEmpty: Bool
    /// The preference values produced by the view and its children.
    public var preferences: PreferenceValues
    /// If a view can ever get focused out of the box, this needs to be set to true,
    /// to be compatible with `@FocusState`.
    public var isNeverFocusable = true

    public init(
        size: ViewSize,
        participateInStackLayoutsWhenEmpty: Bool = false,
        preferences: PreferenceValues
    ) {
        self.size = size
        self.participateInStackLayoutsWhenEmpty = participateInStackLayoutsWhenEmpty
        self.preferences = preferences
    }

    /// Creates a layout result by combining a parent view's sizing and its
    /// children's preference values.
    public init(
        size: ViewSize,
        childResults: [ViewLayoutResult],
        participateInStackLayoutsWhenEmpty: Bool = false,
        preferencesOverlay: PreferenceValues? = nil
    ) {
        self.size = size
        self.participateInStackLayoutsWhenEmpty = participateInStackLayoutsWhenEmpty

        preferences = PreferenceValues(
            merging: childResults.map(\.preferences)
                + [preferencesOverlay].compactMap { $0 }
        )
    }

    /// Creates the layout result of a leaf view (one with no children and no
    /// special preference behaviour). Uses ``PreferenceValues/default``.
    public static func leafView(size: ViewSize) -> Self {
        ViewLayoutResult(
            size: size,
            participateInStackLayoutsWhenEmpty: true,
            preferences: .default
        )
    }

    /// Whether the view should participate in stack layouts (i.e. get its own spacing).
    public var participatesInStackLayouts: Bool {
        size != .zero || participateInStackLayoutsWhenEmpty
    }

    /// Returns a copy of the result with the specified property set to the
    /// provided new value.
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ newValue: T) -> Self {
        var result = self
        result[keyPath: keyPath] = newValue
        return result
    }
}
