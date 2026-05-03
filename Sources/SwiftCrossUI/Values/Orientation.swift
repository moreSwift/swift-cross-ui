/// The orientation of a view (usually in reference to a stack view).
public enum Orientation: Sendable {
    /// The horizontal orientation.
    case horizontal
    /// The vertical orientation.
    case vertical

    /// The orientation perpendicular to this one.
    var perpendicular: Orientation {
        switch self {
            case .horizontal:
                .vertical
            case .vertical:
                .horizontal
        }
    }
}
