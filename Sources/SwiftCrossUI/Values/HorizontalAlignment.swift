/// Alignment of items layed out along the horizontal axis.
public enum HorizontalAlignment: Sendable {
    /// Leading alignment (left alignment in left-to-right locales).
    case leading
    /// Center alignment.
    case center
    /// Trailing alignment (right alignment in left-to-right locales).
    case trailing

    /// Converts this value to a ``StackAlignment``.
    var asStackAlignment: StackAlignment {
        switch self {
            case .leading:
                .leading
            case .center:
                .center
            case .trailing:
                .trailing
        }
    }

    /// Gets the position of a child of a given width in a frame of a given
    /// width using the alignment.
    /// - Parameter childWidth: The width of the child.
    /// - Parameter frameWidth: The width of the frame.
    /// - Returns: The position of the child.
    func position(ofChild childWidth: Double, in frameWidth: Double) -> Double {
        switch self {
            case .leading: 0
            case .center: (frameWidth - childWidth) / 2
            case .trailing: frameWidth - childWidth
        }
    }
}
