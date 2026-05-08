/// A normalized 2D point in a view's coordinate space.
///
/// The point's coordinates start from the view's top leading corner, and
/// are relative to the views size.
///
/// Coordinates between 0 and 1 are inside the bounds of the view, and coordinates
/// outside of that range are outside of the view.
public struct UnitPoint: Hashable, Sendable {
    /// The normalized distance from the origin to the point in the horizontal direction.
    public var x: Double
    /// The normalized distance from the origin to the point in the vertical dimension.
    public var y: Double

    /// Creates a unit point with the specified horizontal and vertical offsets.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    /// Creates a unit point at the origin.
    public init() {
        self.x = 0
        self.y = 0
    }
}

extension UnitPoint {
    /// The origin of a view, in the top, leading corner.
    public static let zero = UnitPoint()

    /// A point that's in the top, leading corner of a view.
    public static let topLeading = UnitPoint(x: 0, y: 0)
    /// A point that's centered horizontally on the top edge of a view.
    public static let top = UnitPoint(x: 0.5, y: 0)
    /// A point that's in the top, trailing corner of a view.
    public static let topTrailing = UnitPoint(x: 1, y: 0)

    /// A point that's centered vertically on the leading edge of a view.
    public static let leading = UnitPoint(x: 0, y: 0.5)
    /// A point that's centered vertically on the trailing edge of a view.
    public static let trailing = UnitPoint(x: 1, y: 0.5)
    /// A point that's centered in a view.
    public static let center = UnitPoint(x: 0.5, y: 0.5)

    /// A point that's in the bottom, leading corner of a view.
    public static let bottomLeading = UnitPoint(x: 0, y: 1)
    /// A point that's centered horizontally on the bottom edge of a view.
    public static let bottom = UnitPoint(x: 0.5, y: 1)
    /// A point that's in the bottom, trailing corner of a view.
    public static let bottomTrailing = UnitPoint(x: 1, y: 1)
}
