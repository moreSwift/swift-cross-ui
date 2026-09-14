/// The proposed size for a view. `nil` signifies an unspecified dimension.
public struct ProposedViewSize: Hashable, Sendable {
    /// The zero proposal.
    public static let zero = Self(0, 0)
    /// The infinite proposal.
    public static let infinity = Self(.infinity, .infinity)
    /// The unspecified/ideal proposal.
    public static let unspecified = Self(nil, nil)

    /// The proposed width (if any).
    public var width: Double?
    /// The proposed height (if any).
    public var height: Double?

    /// The proposal as a concrete view size if both dimensions are specified.
    var concrete: ViewSize? {
        if let width, let height {
            ViewSize(width, height)
        } else {
            nil
        }
    }

    /// Creates a view size proposal.
    public init(_ width: Double?, _ height: Double?) {
        self.width = width
        self.height = height
    }

    public init(_ viewSize: ViewSize) {
        self.width = viewSize.width
        self.height = viewSize.height
    }

    init(_ vector: SIMD2<Int>) {
        self.width = Double(vector.x)
        self.height = Double(vector.y)
    }

    /// Replaces unspecified dimensions of a proposed view size with dimensions
    /// from a concrete view size to get a concrete proposal.
    public func replacingUnspecifiedDimensions(by size: ViewSize) -> ViewSize {
        ViewSize(
            width ?? size.width,
            height ?? size.height
        )
    }

    /// The component associated with the given orientation.
    public subscript(component orientation: Orientation) -> Double? {
        get {
            switch orientation {
                case .horizontal:
                    width
                case .vertical:
                    height
            }
        }
        set {
            switch orientation {
                case .horizontal:
                    width = newValue
                case .vertical:
                    height = newValue
            }
        }
    }

    /// The component associated with the given axis.
    public subscript(component axis: Axis) -> Double? {
        get {
            self[component: axis.orientation]
        }
        set {
            self[component: axis.orientation] = newValue
        }
    }

    public static func - (left: Self, right: SIMD2<Int>) -> Self {
        var left = left
        if let width = left.width {
            left.width = max(0, width - Double(right.x))
        }
        if let height = left.height {
            left.height = max(0, height - Double(right.y))
        }
        return left
    }
}
