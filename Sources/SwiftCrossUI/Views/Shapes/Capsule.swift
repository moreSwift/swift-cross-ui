/// A rounded rectangle whose corner radius is equal to half the length of its
/// shortest side.
public struct Capsule: InsettableShape {
    /// Creates a ``Capsule`` instance.
    public nonisolated init() {}

    public nonisolated func path(in bounds: Path.Rect) -> Path {
        let radius = min(bounds.width, bounds.height) / 2.0
        return RoundedRectangle(cornerRadius: radius).path(in: bounds)
    }

    public nonisolated func inset(by amount: Double) -> some InsettableShape {
        InsettableShapeImpl(inset: amount, base: self)
    }
}
