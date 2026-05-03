/// Represents the available detents (heights) for a sheet presentation.
public enum PresentationDetent: Sendable, Hashable {
    /// A detent that represents a medium height sheet.
    case medium

    /// A detent that represents a large (full-height) sheet.
    case large

    /// A detent at a custom fractional height (between 0 and 1) of the
    /// available space.
    ///
    /// Falls back to ``medium`` on iOS 15.
    case fraction(Double)

    /// A detent at a specific fixed height in points.
    ///
    /// Falls back to ``medium`` on iOS 15.
    case height(Double)
}
